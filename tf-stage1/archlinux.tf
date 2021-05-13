terraform {
  backend "pg" {
    schema_name = "terraform_remote_state_stage1"
  }
}

data "external" "vault_hetzner" {
  program = [
    "${path.module}/../misc/get_key.py", "misc/vault_hetzner.yml",
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
  #   - zone (optionel, required for pkgbuild.com machines)
  #
  # Example:
  # "archlinux.org" = {
  #   server_type = "cpx11"
  #   domain      = "@"
  #   ttl         = 600
  # }
  machines = {
    "archlinux.org" = {
      server_type = "cpx11"
      domain      = "@"
    }
    "accounts.archlinux.org" = {
      server_type = "cx11"
      domain      = "accounts"
    }
    "aur-dev.archlinux.org" = {
      server_type = "cx11"
      domain      = "aur-dev"
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
    "gitlab.archlinux.org" = {
      server_type = "cx51"
      domain      = "gitlab"
    }
    "homedir.archlinux.org" = {
      server_type = "cx11"
      domain      = "homedir"
    }
    "lists.archlinux.org" = {
      server_type = "cx11"
    }
    "mail.archlinux.org" = {
      server_type = "cx11"
      domain      = "mail"
    }
    "mailman3.archlinux.org" = {
      server_type = "cx11"
      domain      = "mailman3"
    }
    "man.archlinux.org" = {
      server_type = "cx11"
      domain      = "man"
    }
    "matrix.archlinux.org" = {
      server_type = "cpx31"
      domain      = "matrix"
    }
    "monitoring.archlinux.org" = {
      server_type = "cx31"
      domain      = "monitoring"
    }
    "dashboards.archlinux.org" = {
      server_type = "cx11"
      domain      = "dashboards"
    }
    "patchwork.archlinux.org" = {
      server_type = "cx11"
      domain      = "patchwork"
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
    "reproducible.archlinux.org" = {
      server_type = "cx11"
      domain      = "reproducible"
    }
    "security.archlinux.org" = {
      server_type = "cx11"
      domain      = "security"
    }
    "svn2gittest.archlinux.org" = {
      server_type = "cx11"
      domain      = "svn2gittest"
    }
    "wiki.archlinux.org" = {
      server_type = "cpx21"
      domain      = "wiki"
    }
    "mirror.pkgbuild.com" = {
      server_type = "cx11"
      domain      = "mirror"
      zone        = hetznerdns_zone.pkgbuild.id
    }
    "md.archlinux.org" = {
      server_type = "cx11"
      domain      = "md"
    }
  }

  # This creates gitlab pages varification entries.
  # Every line consists of "key" = "value":
  #   - key equals the pages subdomain
  #   - value equals the pages verification code
  #
  archlinux_org_gitlab_pages = {
    "conf"                  = "60a06a1c02e42b36c3b4919f4d6de6bf"
    "whatcanidofor"         = "d9e45851002a623e10f6954ff9a85d21"
    "openpgpkey"            = "7533dfbf3947a5730d9cbcc1e5e63102"
    "openpgpkey.master-key" = "5c7f9c249885c62287dd75d0c1dd99d8"
    "bugs-old"              = "1f3308c8d5763eecb4f9013291aeeac4"
    "tu-bylaws.aur"         = "bbafd3ed82f336e0c52d3eb9774b2432"
  }

  # This creates archlinux.org TXT DNS entries
  # Valid parameters are:
  #   - ttl (optional)
  #   - value (mandatory)
  #
  # Example:
  # "_github-challenge-archlinux" = { ttl = 600, value = "824af4446e" }
  archlinux_org_txt = {
    "luna._domainkey.lists"           = { ttl = 600, value = "v=DKIM1; k=rsa; s=email; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvXrAPvtdX8Jrk4zmyk8w9T2zdAJGe7z0+4XHWWiuzH8Zse6S7oXiS9CVaPOsu0TZqHqhuclASU7qh0NXFwWyi2xRPyJOqH2Clu7vHS3j5F4TjURFOp4/EbA0iQu4rbItl4AU11z2pGSEj5SykUsrH+jjdqzNqAG9d4lNvkTs6RRzPF3KhhY+XljaeysEyDSS4ap4E0DYcduSIX\" \"oD1exFv4SEbXThD9PC1u81w4xusnmwmfHtR7aazeqPDP+S+FqDRy2woCaQb/VMbqMYVuWTVKJ2RxFyTKredOOV2c5kzih7GViwoetll/rTqO4aVbeir9K4f6YZg85dSQtVwEat7LV+zBnQwp3ivWkrIk8VEdSsCSaJlgattBiPHsfFFv1xw4qi3h+UvfCGgz35dtlnzd/noGhNARg0Z+kaMSTjy75V1mKx5sCH0o8nAX2XU8akJfLz58Vg\" \"kTx/sfealtwNA0gTy1t1jV8q0OF5RA0IeMRgCzeH2USOZI98W+EAUsGG5653Vzmp3FJRWp1tWJwRJ0M/aZ3ka/G1iTx3rNNcadVk+4q3gz3KnlAlun+m58y8pNWKjYuxmu9xkDRwM/33rv98j0R8HZO7HFL+1vjKkxSEuzmnTQ2O9F76/OsQoDPZ1Z6nJRvK8ts8PQr4ASKohby62+1F1M8U2Xn7u84dYLUCAwEAAQ==" }
    "dkim-ed25519._domainkey"         = { ttl = 600, value = "v=DKIM1; k=ed25519; p=XOHB7b7V1puX+FryNIhsjXHYIFqk+q6JRu4XQ7Jc8MQ=" }
    "dkim-rsa._domainkey"             = { ttl = 600, value = "v=DKIM1; k=rsa; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1GjGrEczq7iHZbvT7wa4ltJz2jwSndUGdRHgfEPnGBeevOXEAlEFr4zsdkfZEaNaQLIhZNpvKAt/A+kkyalkj4u9AnxqeNsNmZflFl6TKgvh0tWNEP3+XNxfdQ7zfml4WggL/YdAjXngg42oZEUsnS/6iozOFn7bNvzqBx5PFJ21pgyuR8DWyLaeOt+p55dVed7DCKnKi11Xjiu7k\" \"H68W8rose7g8Fv9fecBatEE4jwloOXsjh+tH0iab1NSSSpIq6EdgcPrpmrllN3/n2J/kCGK6ztISB6vR7xWgvgHSMjmEL0GPWzohGPrw2UQhZhrNV8dJpiLRYmfK+rXaKF0Kqag/F0e4C4jCKFX7NYFcYXYRlN5QlDFjZvUmOILlgnZ8w/SdZUKzpLObGuwnANLG+WSOjw42p9mXVGN6AfOQPu8OjRjS1MyhcdDIbUvZiQjbmiVJ5frpYZ39BTg\" \"CIzYLJJ5932+3gnwROu1OeljWkpBkfHZXPzADus80l3Vxsk91XZVB36rN8tyuMownR/M4HNC7ZE/EBwOnn1mGH7bLd6pva8u5Qy8Y6LrDdYea5Kk7aZ2WJSSRTV+nkPvOEIx+DfsIWNfmkVWzmuVky96fRvwOCuh38w8zpmlqzhDuGSQrBaLFXwAC7LYQ6kPDHzrjQhs99ScR0ix6YclrmpimMcCAwEAAQ==" }
    "_dmarc"                          = { value = "v=DMARC1; p=none; rua=mailto:dmarc-reports@archlinux.org; ruf=mailto:dmarc-reports@archlinux.org;" }
    "_github-challenge-archlinux"     = { value = "824af4446e" }
    "_github-challenge-archlinux.www" = { value = "b53f311f86" }

    # TLS-RPT + MTA-STS + SPF
    "_smtp._tls"            = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    "_smtp._tls.aur"        = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    "_smtp._tls.master-key" = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    "_smtp._tls.lists"      = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    # Generated with: date +%s
    "_mta-sts"   = { ttl = 600, value = "v=STSv1; id=1608210175" }
    "@"          = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all", ttl = 600 }
    "mail"       = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all", ttl = 600 }
    "aur"        = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all", ttl = 600 }
    "master-key" = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all", ttl = 600 }
    lists        = { ttl = 600, value = "v=spf1 ip4:5.9.250.164 ip6:2a01:4f8:160:3033::2 ~all" }
    luna         = { ttl = 600, value = "v=spf1 ip4:5.9.250.164 ip6:2a01:4f8:160:3033::2 ~all" }
  }

  # This creates archlinux.org MX DNS entries
  # Valid parameters are:
  #   - mx (mandatory)
  #   - ttl (optional)
  #
  # Example:
  # "lists" = { mx = "luna", ttl = 600 }
  archlinux_org_mx = {
    "@"        = { mx = "mail", ttl = 600 }
    aur        = { mx = "mail", ttl = 600 }
    master-key = { mx = "mail", ttl = 600 }
    lists      = { mx = "luna", ttl = 600 }
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
  #   ttl          = 600
  # }
  archlinux_org_a_aaaa = {
    aur4 = {
      ipv4_address = "5.9.250.164"
      ipv6_address = "2a01:4f8:160:3033::2"
    }
    build = {
      ipv4_address = "135.181.138.48"
      ipv6_address = "2a01:4f9:3a:120f::2"
    }
    gemini = {
      ipv4_address = "49.12.124.107"
      ipv6_address = "2a01:4f8:242:5614::2"
    }
    lists = {
      ipv4_address = "5.9.250.164"
      ipv6_address = "2a01:4f8:160:3033::2"
      ttl          = 600
    }
    luna = {
      ipv4_address = "5.9.250.164"
      ipv6_address = "2a01:4f8:160:3033::2"
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
      ipv4_address = "84.17.49.250"
      ipv6_address = "2a02:6ea0:c719::2"
    }
    runner2 = {
      ipv4_address = "147.75.80.217"
      ipv6_address = "2604:1380:2001:4500::3"
    }
    secure-runner1 = {
      ipv4_address = "116.202.134.150"
      ipv6_address = "2a01:4f8:231:4e1e::2"
    }
    state = {
      ipv4_address = "116.203.16.252"
      ipv6_address = "2a01:4f8:c2c:474::1"
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
  # dev                      = { value = "www", ttl = 600 }
  archlinux_org_cname = {
    archive       = { value = "gemini" }
    dev           = { value = "www" }
    g2kjxsblac7x  = { value = "gv-i5y6mnrelvpfiu.dv.googlehosted.com." }
    git           = { value = "luna" }
    ipxe          = { value = "www" }
    mailman       = { value = "redirect" }
    packages      = { value = "www" }
    ping          = { value = "redirect" }
    planet        = { value = "www" }
    projects      = { value = "luna" }
    repos         = { value = "gemini" }
    rsync         = { value = "gemini" }
    sources       = { value = "gemini" }
    "static.conf" = { value = "redirect" }
    logging       = { value = "monitoring" }
    status        = { value = "stats.uptimerobot.com." }
    svn           = { value = "gemini" }

    # MTA-STS
    mta-sts               = { value = "mail" }
    "mta-sts.aur"         = { value = "mail" }
    "_mta-sts.aur"        = { value = "_mta-sts", ttl = 600 }
    "mta-sts.master-key"  = { value = "mail" }
    "_mta-sts.master-key" = { value = "_mta-sts", ttl = 600 }
    "mta-sts.lists"       = { value = "mail" }
    "_mta-sts.lists"      = { value = "_mta-sts", ttl = 600 }
  }

  # This creates pkgbuild.comA/AAAA DNS entries in addition to those already specified by the VPSes.
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
}

resource "hetznerdns_zone" "archlinux" {
  name = "archlinux.org"
  ttl  = 86400
}

resource "hetznerdns_zone" "pkgbuild" {
  name = "pkgbuild.com"
  ttl  = 86400
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
  value   = "robotns3.second-ns.com."
  type    = "NS"
}

resource "hetznerdns_record" "pkgbuild_com_origin_ns2" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "robotns2.second-ns.de."
  type    = "NS"
}

resource "hetznerdns_record" "pkgbuild_com_origin_ns1" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "ns1.first-ns.de."
  type    = "NS"
}

# TODO: Commented currently as we have no idea how to handle SOA stuff with Terraform:
# https://github.com/timohirt/terraform-provider-hetznerdns/issues/20
# https://gitlab.archlinux.org/archlinux/infrastructure/-/merge_requests/62#note_4040
# resource "hetznerdns_record" "pkgbuild_com_origin_soa" {
#   zone_id = hetznerdns_zone.pkgbuild.id
#   name = "@"
#   value = "ns1.first-ns.de. dns.hetzner.com. 2020090604 14400 1800 604800 86400"
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
  value   = "robotns3.second-ns.com."
  type    = "NS"
}

resource "hetznerdns_record" "archlinux_org_origin_ns2" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "robotns2.second-ns.de."
  type    = "NS"
}

resource "hetznerdns_record" "archlinux_org_origin_ns1" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "ns1.first-ns.de."
  type    = "NS"
}

# TODO: Commented currently as we have no idea how to handle SOA stuff with Terraform:
# https://github.com/timohirt/terraform-provider-hetznerdns/issues/20
# https://gitlab.archlinux.org/archlinux/infrastructure/-/merge_requests/62#note_4040
#; resource "hetznerdns_record" "archlinux_org_origin_soa" {
#   zone_id = hetznerdns_zone.archlinux.id
#   name = "@"
#   value = "ns1.first-ns.de. ibiru.archlinux.org. 2020072502 7200 900 1209600 86400"
#   type = "SOA"
# }

resource "hetznerdns_record" "archlinux_org_matrix_tcp_srv" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "_matrix._tcp"
  value   = "10 0 8448 matrix"
  type    = "SRV"
}

resource "hcloud_floating_ip" "gitlab_pages" {
  type        = "ipv4"
  description = "GitLab Pages"
  server_id   = hcloud_server.machine["gitlab.archlinux.org"].id
}

variable "gitlab_pages_ipv6" {
  default = "2a01:4f8:c2c:5d2d::2"
}

resource "hcloud_volume" "gitlab" {
  name      = "gitlab"
  size      = 1000
  server_id = hcloud_server.machine["gitlab.archlinux.org"].id
}

resource "hcloud_volume" "mirror" {
  name      = "mirror"
  size      = 100
  server_id = hcloud_server.machine["mirror.pkgbuild.com"].id
}

resource "hcloud_volume" "homedir" {
  name      = "homedir"
  size      = 100
  server_id = hcloud_server.machine["homedir.archlinux.org"].id
}

resource "hcloud_volume" "monitoring" {
  name      = "monitoring"
  size      = 100
  server_id = hcloud_server.machine["monitoring.archlinux.org"].id
}
