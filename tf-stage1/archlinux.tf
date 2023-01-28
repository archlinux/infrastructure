terraform {
  backend "pg" {
    schema_name = "terraform_remote_state_stage1"
  }
}

data "external" "vault_hetzner" {
  program = [
    "${path.module}/../misc/get_key.py", "${path.module}/../misc/vaults/vault_hetzner.yml",
    "hetzner_cloud_api_key",
    "hetzner_dns_api_key",
    "--format", "json"
  ]
}

data "hcloud_image" "archlinux" {
  with_selector = "custom_image=archlinux"
  most_recent   = true
  with_status   = ["available"]
}

provider "hcloud" {
  token = data.external.vault_hetzner.result.hetzner_cloud_api_key
}

provider "hetznerdns" {
  apitoken = data.external.vault_hetzner.result.hetzner_dns_api_key
}

locals {
  # These are the Hetzner Cloud VPSes.
  # Every entry creates:
  #   - the machine
  #   - the rdns entries
  #   - A and AAAA entries
  #
  # Valid parameters are:
  #   - server_type (mandatory)
  #   - domain (optional, creates dns entry <domain>.archlinux.org pointing to the machine)
  #   - ttl (optional, applies to the dns entries)
  #   - zone (optional, required for pkgbuild.com machines)
  #
  # Example:
  # "archlinux.org" = {
  #   server_type = "cpx11"
  #   domain      = "@"
  #   ttl         = 3600
  # }
  machines = {
    "accounts.archlinux.org" = {
      server_type = "cx11"
      domain      = "accounts"
    }
    "archlinux.org" = {
      server_type = "cpx11"
      domain      = "@"
    }
    "aur.archlinux.org" = {
      server_type = "cpx41"
      domain      = "aur"
    }
    "bbs.archlinux.org" = {
      server_type = "cx21"
      domain      = "bbs"
    }
    "bugs.archlinux.org" = {
      server_type = "cx11"
      domain      = "bugs"
    }
    "buildbot.pkgbuild.com" = {
      server_type = "cx21"
      domain      = "buildbot"
      zone        = hetznerdns_zone.pkgbuild.id
    }
    "dashboards.archlinux.org" = {
      server_type = "cx11"
      domain      = "dashboards"
    }
    "debuginfod.archlinux.org" = {
      server_type = "cpx11"
      domain      = "debuginfod"
    }
    "gitlab.archlinux.org" = {
      server_type = "cpx41"
      domain      = "gitlab"
    }
    "gluebuddy.archlinux.org" = {
      server_type = "cx11"
      domain      = "gluebuddy"
    }
    "homedir.archlinux.org" = {
      server_type = "cx11"
      domain      = "homedir"
    }
    "lists.archlinux.org" = {
      server_type = "cx21"
      domain      = "lists"
    }
    "mail.archlinux.org" = {
      server_type = "cx11"
      domain      = "mail"
    }
    "man.archlinux.org" = {
      server_type = "cx11"
      domain      = "man"
    }
    "matrix.archlinux.org" = {
      server_type = "cpx31"
      domain      = "matrix"
    }
    "md.archlinux.org" = {
      server_type = "cx11"
      domain      = "md"
    }
    "mirror.pkgbuild.com" = {
      server_type = "cx11"
      domain      = "mirror"
      zone        = hetznerdns_zone.pkgbuild.id
    }
    "monitoring.archlinux.org" = {
      server_type = "cx31"
      domain      = "monitoring"
    }
    "phrik.archlinux.org" = {
      server_type = "cx11"
      domain      = "phrik"
    }
    "quassel.archlinux.org" = {
      server_type = "cx11"
      domain      = "quassel"
    }
    "redirect.archlinux.org" = {
      server_type = "cx11"
      domain      = "redirect"
    }
    "repos-git.archlinux.org" = {
      server_type = "cpx11"
      domain      = "repos-git"
    }
    "repos.sandbox.archlinux.org" = {
      server_type = "cpx21"
      domain      = "repos.sandbox"
    }
    "reproducible.archlinux.org" = {
      server_type = "cx11"
      domain      = "reproducible"
    }
    "security.archlinux.org" = {
      server_type = "cx11"
      domain      = "security"
    }
    "state.archlinux.org" = {
      server_type = "cx11"
      domain      = "state"
      backups     = true
    }
    "wiki.archlinux.org" = {
      server_type = "cpx21"
      domain      = "wiki"
    }
  }

  # This creates gitlab pages verification entries.
  # Every line consists of "key" = "value":
  #   - key equals the pages subdomain
  #   - value equals the pages verification code
  #
  archlinux_org_gitlab_pages = {
    "conf"                  = "60a06a1c02e42b36c3b4919f4d6de6bf"
    "whatcanidofor"         = "d9e45851002a623e10f6954ff9a85d21"
    "openpgpkey"            = "d20c137368e26dcc3db56d45a368e729"
    "openpgpkey.master-key" = "3eea8f39a9b473a5dc7c188366f84072"
    "bugs-old"              = "1f3308c8d5763eecb4f9013291aeeac4"
    "tu-bylaws.aur"         = "bbafd3ed82f336e0c52d3eb9774b2432"
    "reproducible-notes"    = "8c657f2f2720db1c3db63be89605cf0d"
    "terms"                 = "0b62a71af2aa85fb491295b543b4c3d2"
    "patchwork"             = "37eeadf24d5cd6614e8edb1f12868a5e"
  }

  archlinux_page_gitlab_pages = {
    "repod"           = "f2d1ad84f7e9f22cd881d3bef58263e0"
    "rfc"             = "b457db2ce4ac4e162d2f4435f1fe1f39"
    "monthly-reports" = "a2d60657e960b480cdb229df7cc7edf3"
  }

  # This creates archlinux.org TXT DNS entries
  # Valid parameters are:
  #   - ttl (optional)
  #   - value (mandatory)
  #
  # Example:
  # "_github-challenge-archlinux" = { ttl = 3600, value = "824af4446e" }
  archlinux_org_txt = {
    "dkim-ed25519._domainkey.lists" = { value = "v=DKIM1; k=ed25519;p=ongbdFgt5Vimg/VRRbbSVRU4lBCkcYNaPA4K3JS/DnY=" }
    "dkim-rsa._domainkey.lists"     = { value = "v=DKIM1; k=rsa; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA4M+y3ZeB9eI3GVgcrvMcI1SYOveH7P5TTRstaCHTlE/aRTiCzu5h6zKwwxEiK6NR5ugbHpBtfFnfnsl1eoaXVFBQfNdDNglHllJOZGVxTnyrFjRJUk9zN+PV/Haz73nAe1hOAENgV8NKnTok1ntaOYSH1AEj4yTswfQkuN23NPrQc1eyy3+hGC+lYpud3xAAl+oT4QE76PaLgk6Hz\" \"HOvZmAPGD3azJZRbobninZZXTAEvZFuPkfpWeUreDU9Hk9VX3zOmnqTN+YjIS5CdV6+Ghem3dCkmR9j3gOZBeBUYD7b+cinTYe/PZO2OG/LWCwN11EYyf1LSBGhBJCF9HPGiGIdhy5T62nKvwDQS0bj1HL+y6pXZdv2C7KgH+lAZ0idpOQ2TtV5e0tlVdryY4QXY9m7mSQ84WsoEdGDsetOhiTEKuqyGnDoYa0wYbM5477LL6EOzS0x3ZC/mbOg\" \"B+FSdzmLWCH/WjuzMNpw9WU+u4BucwVbYcnZ1vAxQQOEnA/Ku9drRHMFixBwodQuMA78j8ICCMJKlUiXmbbL7OFoXBArYJ7lgVs7mlaoEaqzDPCyqs1lJ9kOxdNoZj5zdxERcQhLm+Yo/948i6Js/nkWT0eAjNlHxZuCg3B4z7L4lRZpaGt+vHdcGUIeDKW34O0dWxPwIUmQA4CwmhUB0HWL9UcCAwEAAQ==" }
    "dkim-ed25519._domainkey"       = { value = "v=DKIM1; k=ed25519; p=XOHB7b7V1puX+FryNIhsjXHYIFqk+q6JRu4XQ7Jc8MQ=" }
    "dkim-rsa._domainkey"           = { value = "v=DKIM1; k=rsa; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1GjGrEczq7iHZbvT7wa4ltJz2jwSndUGdRHgfEPnGBeevOXEAlEFr4zsdkfZEaNaQLIhZNpvKAt/A+kkyalkj4u9AnxqeNsNmZflFl6TKgvh0tWNEP3+XNxfdQ7zfml4WggL/YdAjXngg42oZEUsnS/6iozOFn7bNvzqBx5PFJ21pgyuR8DWyLaeOt+p55dVed7DCKnKi11Xjiu7k\" \"H68W8rose7g8Fv9fecBatEE4jwloOXsjh+tH0iab1NSSSpIq6EdgcPrpmrllN3/n2J/kCGK6ztISB6vR7xWgvgHSMjmEL0GPWzohGPrw2UQhZhrNV8dJpiLRYmfK+rXaKF0Kqag/F0e4C4jCKFX7NYFcYXYRlN5QlDFjZvUmOILlgnZ8w/SdZUKzpLObGuwnANLG+WSOjw42p9mXVGN6AfOQPu8OjRjS1MyhcdDIbUvZiQjbmiVJ5frpYZ39BTg\" \"CIzYLJJ5932+3gnwROu1OeljWkpBkfHZXPzADus80l3Vxsk91XZVB36rN8tyuMownR/M4HNC7ZE/EBwOnn1mGH7bLd6pva8u5Qy8Y6LrDdYea5Kk7aZ2WJSSRTV+nkPvOEIx+DfsIWNfmkVWzmuVky96fRvwOCuh38w8zpmlqzhDuGSQrBaLFXwAC7LYQ6kPDHzrjQhs99ScR0ix6YclrmpimMcCAwEAAQ==" }

    "_dmarc"                          = { value = "v=DMARC1; p=none; rua=mailto:dmarc-reports@archlinux.org; ruf=mailto:dmarc-reports@archlinux.org;" }
    "_github-challenge-archlinux"     = { value = "824af4446e" }
    "_github-challenge-archlinux.www" = { value = "b53f311f86" }

    # TLS-RPT + MTA-STS + SPF
    "_smtp._tls"            = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    "_smtp._tls.aur"        = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    "_smtp._tls.master-key" = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    "_smtp._tls.lists"      = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    # Generated with: date +%Y%m%d01
    "_mta-sts"   = { value = "v=STSv1; id=2022051602" }
    "@"          = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all" }
    "mail"       = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all" }
    "aur"        = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all" }
    "master-key" = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all" }
    lists        = { value = "v=spf1 ip4:${hcloud_server.machine["lists.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["lists.archlinux.org"].ipv6_address} ~all" }
  }

  # This creates archlinux.org MX DNS entries
  # Valid parameters are:
  #   - mx (mandatory)
  #   - ttl (optional)
  #
  # Example:
  # "lists" = { mx = "lists", ttl = 3600 }
  archlinux_org_mx = {
    "@"        = { mx = "mail" }
    aur        = { mx = "mail" }
    master-key = { mx = "mail" }
    lists      = { mx = "lists" }
  }

  # This creates archlinux.org A/AAAA DNS entries in addition to those already specified by the VPSes.
  # The VPSes already get a default domain assigned based on their domain parameter.
  # Thus the domains in local.archlinux_org_a_aaaa are additional domains or domains assigned to dedicated servers.
  #
  # The entry name corresponds to the subdomain.
  # '@' is the root doman (archlinux.org).
  # Valid parameters are:
  #   - ipv4_address (mandatory)
  #   - ipv6_address (mandatory)
  #   - ttl (optional)
  #
  # Example:
  # gemini = {
  #   ipv4_address = "49.12.124.107"
  #   ipv6_address = "2a01:4f8:242:5614::2"
  #   ttl          = 3600
  # }
  archlinux_org_a_aaaa = {
    build = {
      ipv4_address = "135.181.138.48"
      ipv6_address = "2a01:4f9:3a:120f::2"
    }
    gemini = {
      ipv4_address = "49.12.124.107"
      ipv6_address = "2a01:4f8:242:5614::2"
    }
    master-key = {
      ipv4_address = hcloud_server.machine["archlinux.org"].ipv4_address
      ipv6_address = hcloud_server.machine["archlinux.org"].ipv6_address
    }
    pages = {
      ipv4_address = hcloud_floating_ip.gitlab_pages.ip_address
      ipv6_address = var.gitlab_pages_ipv6
    }
    runner1 = {
      ipv4_address = "138.199.19.15"
      ipv6_address = "2a02:6ea0:c72e::2"
    }
    runner2 = {
      ipv4_address = "147.75.80.217"
      ipv6_address = "2604:1380:2001:4500::3"
    }
    secure-runner1 = {
      ipv4_address = "116.202.134.150"
      ipv6_address = "2a01:4f8:231:4e1e::2"
    }
    www = {
      ipv4_address = hcloud_server.machine["archlinux.org"].ipv4_address
      ipv6_address = hcloud_server.machine["archlinux.org"].ipv6_address
    }
  }

  # This creates archlinux.org CNAME DNS entries.
  # Valid parameters are:
  #   - value (mandatory, the target for the CNAME "redirect")
  #   - ttl (optional)
  #
  # Example:
  # dev                      = { value = "www", ttl = 3600 }
  archlinux_org_cname = {
    archive         = { value = "gemini" }
    dev             = { value = "www" }
    g2kjxsblac7x    = { value = "gv-i5y6mnrelvpfiu.dv.googlehosted.com." }
    ipxe            = { value = "www" }
    mailman         = { value = "redirect" }
    packages        = { value = "www" }
    ping            = { value = "redirect" }
    planet          = { value = "www" }
    repos           = { value = "gemini" }
    rsync           = { value = "gemini" }
    "rsync.sandbox" = { value = "repos.sandbox" }
    sources         = { value = "gemini" }
    "static.conf"   = { value = "redirect" }
    status          = { value = "stats.uptimerobot.com." }
    svn             = { value = "gemini" }
    coc             = { value = "redirect" }
    git             = { value = "redirect" }

    # MTA-STS
    mta-sts               = { value = "mail" }
    "mta-sts.aur"         = { value = "mail" }
    "_mta-sts.aur"        = { value = "_mta-sts" }
    "mta-sts.master-key"  = { value = "mail" }
    "_mta-sts.master-key" = { value = "_mta-sts" }
    "mta-sts.lists"       = { value = "mail" }
    "_mta-sts.lists"      = { value = "_mta-sts" }
  }

  # This creates pkgbuild.com A/AAAA DNS entries in addition to those already specified by the VPSes.
  # The VPSes already get a default domain assigned based on their domain parameter.
  # Thus the domains in local.pkgbuild_com_a_aaaa are additional domains or domains assigned to dedicated servers.
  #
  # The entry name corresponds to the subdomain.
  # '@' is the root doman (pkgbuild.com).
  # Valid parameters are:
  #   - ipv4_address (mandatory)
  #   - ipv6_address (mandatory)
  #   - ttl (optional)
  #
  pkgbuild_com_a_aaaa = {
    "@" = {
      ipv4_address = hcloud_server.machine["homedir.archlinux.org"].ipv4_address
      ipv6_address = hcloud_server.machine["homedir.archlinux.org"].ipv6_address
    }
    "america.mirror" = {
      ipv4_address = "143.244.34.62"
      ipv6_address = "2a02:6ea0:cc0e::2"
    }
    "america.archive" = {
      ipv4_address = "143.244.34.62"
      ipv6_address = "2a02:6ea0:cc0e::2"
    }
    "asia.mirror" = {
      ipv4_address = "84.17.57.98"
      ipv6_address = "2a02:6ea0:d605::2"
    }
    "asia.archive" = {
      ipv4_address = "84.17.57.98"
      ipv6_address = "2a02:6ea0:d605::2"
    }
    "europe.mirror" = {
      ipv4_address = "89.187.191.12"
      ipv6_address = "2a02:6ea0:c237::2"
    }
    "europe.archive" = {
      ipv4_address = "89.187.191.12"
      ipv6_address = "2a02:6ea0:c237::2"
    }
    "seoul.mirror" = {
      ipv4_address = "145.40.87.75"
      ipv6_address = "2604:1380:11:2600::1"
    }
    "sydney.mirror" = {
      ipv4_address = "147.75.48.159"
      ipv6_address = "2604:1380:40f1:6a00::1"
    }
    repro1 = {
      ipv4_address = "147.75.81.79"
      ipv6_address = "2604:1380:2001:4500::1"
    }
    repro2 = {
      ipv4_address = "212.102.38.209"
      ipv6_address = "2a02:6ea0:c238::2"
    }
    www = {
      ipv4_address = hcloud_server.machine["homedir.archlinux.org"].ipv4_address
      ipv6_address = hcloud_server.machine["homedir.archlinux.org"].ipv6_address
    }
  }

  # This creates archlinux.page A/AAAA DNS entries.
  #
  # The entry name corresponds to the subdomain.
  # '@' is the root doman (archlinux.page).
  # Valid parameters are:
  #   - ipv4_address (mandatory)
  #   - ipv6_address (mandatory)
  #   - ttl (optional)
  #
  archlinux_page_a_aaaa = {
    "@" = {
      ipv4_address = hcloud_floating_ip.gitlab_pages.ip_address
      ipv6_address = var.gitlab_pages_ipv6
    }
  }

  # Domains served by machines in the geo_mirrors group
  # Valid parameters are:
  #   - name (mandatory, specifies the subdomain to create in the above zone)
  #   - zone (optional, defaults to hetznerdns_zone.archlinux.id)
  #   - ttl (optional, the TTL of the NS records, defaults to 86400 if unset)
  #
  # Note: If you use a custom TTL, also add it to geo_options[domain]['ns_ttl']
  #       in Ansible (see the 'geo_options' variable in group_vars/all/geo.yml)
  #
  geo_domains = {
    "geo.mirror.pkgbuild.com" = {
      name = "geo.mirror"
      zone = hetznerdns_zone.pkgbuild.id
    }
    "riscv.mirror.pkgbuild.com" = {
      name = "riscv.mirror"
      zone = hetznerdns_zone.pkgbuild.id
    }
  }
}

resource "hetznerdns_zone" "archlinux" {
  name = "archlinux.org"
  ttl  = 3600
}

resource "hetznerdns_zone" "archlinux_page" {
  name = "archlinux.page"
  ttl  = 3600
}

resource "hetznerdns_zone" "pkgbuild" {
  name = "pkgbuild.com"
  ttl  = 3600
}

resource "hetznerdns_record" "archlinux_page_origin_caa" {
  zone_id = hetznerdns_zone.archlinux_page.id
  name    = "@"
  value   = "0 issue \"letsencrypt.org\""
  type    = "CAA"
}

resource "hetznerdns_record" "archlinux_page_origin_mx" {
  zone_id = hetznerdns_zone.archlinux_page.id
  name    = "@"
  value   = "0 ."
  type    = "MX"
}

resource "hetznerdns_record" "archlinux_page_origin_ns3" {
  zone_id = hetznerdns_zone.archlinux_page.id
  name    = "@"
  value   = "helium.ns.hetzner.de."
  type    = "NS"
  ttl     = 86400
}

resource "hetznerdns_record" "archlinux_page_origin_ns2" {
  zone_id = hetznerdns_zone.archlinux_page.id
  name    = "@"
  value   = "oxygen.ns.hetzner.com."
  type    = "NS"
  ttl     = 86400
}

resource "hetznerdns_record" "archlinux_page_origin_ns1" {
  zone_id = hetznerdns_zone.archlinux_page.id
  name    = "@"
  value   = "hydrogen.ns.hetzner.com."
  type    = "NS"
  ttl     = 86400
}

# TODO: Commented currently as we have no idea how to handle SOA stuff with Terraform:
# https://github.com/timohirt/terraform-provider-hetznerdns/issues/20
# https://gitlab.archlinux.org/archlinux/infrastructure/-/merge_requests/62#note_4040
# resource "hetznerdns_record" "archlinux_page_origin_soa" {
#   zone_id = hetznerdns_zone.archlinux_page.id
#   name = "@"
#   value = "hydrogen.ns.hetzner.com. hetzner.archlinux.org. 2021070703 3600 1800 604800 3600"
#   type = "SOA"
# }

resource "hetznerdns_record" "archlinux_page_origin_txt" {
  zone_id = hetznerdns_zone.archlinux_page.id
  name    = "@"
  value   = "\"v=spf1 -all\""
  type    = "TXT"
}

resource "hetznerdns_record" "pages_verification_code_archlinux_page_origin_txt" {
  zone_id = hetznerdns_zone.archlinux_page.id
  name    = "_gitlab-pages-verification-code"
  value   = "gitlab-pages-verification-code=0b9e3fc74735f5d83c7cfc86883b40cb"
  type    = "TXT"
}

resource "hetznerdns_record" "pkgbuild_com_origin_caa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "0 issue \"letsencrypt.org\""
  type    = "CAA"
}

resource "hetznerdns_record" "pkgbuild_com_origin_mx" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "0 ."
  type    = "MX"
}

resource "hetznerdns_record" "pkgbuild_com_origin_ns3" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "helium.ns.hetzner.de."
  type    = "NS"
  ttl     = 86400
}

resource "hetznerdns_record" "pkgbuild_com_origin_ns2" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "oxygen.ns.hetzner.com."
  type    = "NS"
  ttl     = 86400
}

resource "hetznerdns_record" "pkgbuild_com_origin_ns1" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "hydrogen.ns.hetzner.com."
  type    = "NS"
  ttl     = 86400
}

# TODO: Commented currently as we have no idea how to handle SOA stuff with Terraform:
# https://github.com/timohirt/terraform-provider-hetznerdns/issues/20
# https://gitlab.archlinux.org/archlinux/infrastructure/-/merge_requests/62#note_4040
# resource "hetznerdns_record" "pkgbuild_com_origin_soa" {
#   zone_id = hetznerdns_zone.pkgbuild.id
#   name = "@"
#   value = "hydrogen.ns.hetzner.com. hetzner.archlinux.org. 2021070703 3600 1800 604800 3600"
#   type = "SOA"
# }

resource "hetznerdns_record" "pkgbuild_com_origin_txt" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "\"v=spf1 -all\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_origin_caa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "0 issue \"letsencrypt.org\""
  type    = "CAA"
}

resource "hetznerdns_record" "archlinux_org_origin_ns3" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "helium.ns.hetzner.de."
  type    = "NS"
  ttl     = 86400
}

resource "hetznerdns_record" "archlinux_org_origin_ns2" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "oxygen.ns.hetzner.com."
  type    = "NS"
  ttl     = 86400
}

resource "hetznerdns_record" "archlinux_org_origin_ns1" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "hydrogen.ns.hetzner.com."
  type    = "NS"
  ttl     = 86400
}

# TODO: Commented currently as we have no idea how to handle SOA stuff with Terraform:
# https://github.com/timohirt/terraform-provider-hetznerdns/issues/20
# https://gitlab.archlinux.org/archlinux/infrastructure/-/merge_requests/62#note_4040
#; resource "hetznerdns_record" "archlinux_org_origin_soa" {
#   zone_id = hetznerdns_zone.archlinux.id
#   name = "@"
#   value = "hydrogen.ns.hetzner.com. hetzner.archlinux.org. 2021070703 3600 1800 604800 3600"
#   type = "SOA"
# }

resource "hcloud_floating_ip" "gitlab_pages" {
  type              = "ipv4"
  description       = "GitLab Pages"
  server_id         = hcloud_server.machine["gitlab.archlinux.org"].id
  delete_protection = true
}

variable "gitlab_pages_ipv6" {
  default = "2a01:4f8:c2c:5d2d::2"
}

resource "hcloud_volume" "mirror" {
  name              = "mirror"
  size              = 100
  server_id         = hcloud_server.machine["mirror.pkgbuild.com"].id
  delete_protection = true
}

resource "hcloud_volume" "homedir" {
  name              = "homedir"
  size              = 100
  server_id         = hcloud_server.machine["homedir.archlinux.org"].id
  delete_protection = true
}

resource "hcloud_volume" "monitoring" {
  name              = "monitoring"
  size              = 200
  server_id         = hcloud_server.machine["monitoring.archlinux.org"].id
  delete_protection = true
}

resource "hcloud_volume" "debuginfod" {
  name              = "debuginfod"
  size              = 50
  server_id         = hcloud_server.machine["debuginfod.archlinux.org"].id
  delete_protection = true
}

resource "hcloud_volume" "repos-git" {
  name              = "repos-git"
  size              = 100
  server_id         = hcloud_server.machine["repos-git.archlinux.org"].id
  delete_protection = true
}

resource "hcloud_volume" "repos_sandbox" {
  name              = "repos.sandbox"
  size              = 500
  server_id         = hcloud_server.machine["repos.sandbox.archlinux.org"].id
  delete_protection = true
}
