data "external" "vault_fastly" {
  program = ["${path.module}/../misc/get_key.py", "${path.module}/../group_vars/all/vault_fastly.yml",
    "vault_fastly_api_key",
  "--format", "json"]
}

provider "fastly" {
  api_key = data.external.vault_fastly.result.vault_fastly_api_key
}

resource "fastly_service_vcl" "fastly_mirror_pkgbuild_com" {
  name = "Arch Linux Fastly Mirror"

  domain {
    name    = "fastly.mirror.pkgbuild.com"
    comment = "Arch Linux Fastly Mirror"
  }

  backend {
    address           = "mirror.pkgbuild.com"
    name              = "MIRRORPKGBUILD"
    port              = 443
    override_host     = "mirror.pkgbuild.com"
    use_ssl           = true
    ssl_cert_hostname = "mirror.pkgbuild.com"
    ssl_sni_hostname  = "mirror.pkgbuild.com"
    shield            = "frankfurt-de"
    prefer_ipv6       = true
    max_conn          = 1000
  }

  http3 = true

  # use a cache TTL of 24h as the databases are uncached anyways
  default_ttl = 86400

  # Segmented caching only make sense for filetypes that are usually big
  # Note: We need to follow symbolic links (-L) in order to also find big files that symlinks are pointing to because the webserver will serve the target of the symlink (and potentially exceed the allowed filesize)
  # find -L /srv/ftp/ -type f -size +10M -printf "%f\n" | rev | cut -d "." -f 1 | rev | sort --unique
  snippet {
    name    = "Enable segmented caching for packages"
    content = <<-EOT
    # Setup caching for all files to avoid 503 on large packages and files
    if (req.url.ext ~ "^(files|gz|img|iso|old|qcow2|sfs|wsl|zst)\z" || req.url.basename == "vmlinuz-linux") {
      set req.enable_segmented_caching = true;
      set segmented_caching.block_size = 20971520;
    }
    EOT
    type    = "recv"
  }

  snippet {
    name    = "Enable streaming miss"
    content = <<-EOT
    set beresp.do_stream = true;
    EOT
    type    = "fetch"
  }

  header {
    action        = "set"
    destination   = "do_stream"
    name          = "Enable streaming miss"
    type          = "cache"
    priority      = 10
    source        = "true"
    ignore_if_set = false
  }

  # We don't benefit much from gzip as most of our content is zst compressed anyways
  gzip {
    name          = "Disable gzip"
    extensions    = []
    content_types = []
  }

  # Can be used (and the request setting) instead of toggling "force TLS and enable HSTS in UI"
  header {
    action        = "set"
    destination   = "http.Strict-Transport-Security"
    name          = "Enable HSTS"
    type          = "response"
    priority      = 100
    source        = "\"max-age=31536000\""
    ignore_if_set = false
  }

  request_setting {
    name          = "Force TLS"
    force_ssl     = true
    max_stale_age = 0
    xff           = ""
  }

  cache_setting {
    name            = "Skip cache status codes setting"
    action          = "pass"
    cache_condition = "Skip cache status codes"
  }

  condition {
    name      = "Skip cache status codes"
    statement = "beresp.status == 404"
    type      = "CACHE"
    priority  = 5
  }

  # Cache HTML pages for 5 min
  cache_setting {
    name            = "HTML TTL setting"
    cache_condition = "HTML TTL"
    ttl             = 300
  }

  condition {
    name      = "HTML TTL"
    statement = "beresp.http.Content-Type == \"text/html\""
    type      = "CACHE"
    priority  = 10
  }

  condition {
    name      = "Skip date sync files cache"
    statement = "req.url ~ \"^/(lastsync|lastupdate)\""
    type      = "REQUEST"
    priority  = 10
  }

  request_setting {
    name              = "Skip date sync files cache setting"
    action            = "pass"
    request_condition = "Skip date sync files cache"
  }

  force_destroy = true
}

resource "fastly_tls_subscription" "fastly_mirror_pkgbuild_com" {
  domains               = [for domain in fastly_service_vcl.fastly_mirror_pkgbuild_com.domain : domain.name]
  certificate_authority = "lets-encrypt"
}
