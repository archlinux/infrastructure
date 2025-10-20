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
  }

  http3 = true

  # use a cache TTL of 24h as the databases are uncached anyways
  default_ttl = 86400

  snippet {
    name    = "Enable segmented caching for packages"
    content = <<-EOT
    # Setup caching for all files to avoid 503 on large packages and files
    if (req.url.ext ~ "[a-zA-Z0-9]+$") {
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

  condition {
    name      = "Skip stable database cache"
    statement = "req.url ~ \"^/(core/os/x86_64/core.files|core/os/x86_64/core.db|extra/os/x86_64/extra.files|extra/os/x86_64/extra.db|multilib/os/x86_64/multilib.files|multilib/os/x86_64/multilib.db)\""
    type      = "REQUEST"
    priority  = 10
  }

  request_setting {
    name              = "Skip stable database cache setting"
    action            = "pass"
    request_condition = "Skip stable database cache"
  }

  condition {
    name      = "Skip testing database cache"
    statement = "req.url ~ \"^/(core-testing/os/x86_64/core-testing.files|core-testing/os/x86_64/core-testing.db|extra-testing/os/x86_64/extra-testing.files|extra-testing/os/x86_64/extra-testing.db|multilib-testing/os/x86_64/multilib-testing.files|multilib-testing/os/x86_64/multilib-testing.db|kde-unstable/os/x86_64/kde-unstable.files|kde-unstable/os/x86_64/kde-unstable.db|gnome-unstable/os/x86_64/gnome-unstable.files|gnome-unstable/os/x86_64/gnome-unstable.db)\""
    type      = "REQUEST"
    priority  = 10
  }

  request_setting {
    name              = "Skip testing database cache setting"
    action            = "pass"
    request_condition = "Skip testing database cache"
  }

  condition {
    name      = "Skip staging database cache"
    statement = "req.url ~ \"^/(core-staging/os/x86_64/core-staging.files|core-staging/os/x86_64/core-staging.db|extra-staging/os/x86_64/extra-staging.files|extra-staging/os/x86_64/extra-staging.db|multilib-staging/os/x86_64/multilib-staging.files|multilib-staging/os/x86_64/multilib-staging.db)\""
    type      = "REQUEST"
    priority  = 10
  }

  request_setting {
    name              = "Skip staging database cache setting"
    action            = "pass"
    request_condition = "Skip staging database cache"
  }

  force_destroy = true
}

resource "fastly_tls_subscription" "fastly_mirror_pkgbuild_com" {
  domains               = [for domain in fastly_service_vcl.fastly_mirror_pkgbuild_com.domain : domain.name]
  certificate_authority = "lets-encrypt"
}
