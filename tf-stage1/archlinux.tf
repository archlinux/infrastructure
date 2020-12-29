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
  #   - domain (mandatory)
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
    "mail.archlinux.org" = {
      server_type = "cx11"
      domain      = "mail"
    }
    "mailman3.archlinux.org" = {
      server_type = "cx11"
      domain      = "mailman3"
    }
    "matrix.archlinux.org" = {
      server_type = "cpx31"
      domain      = "matrix"
    }
    "monitoring.archlinux.org" = {
      server_type = "cx11"
      domain      = "monitoring"
    }
    "openpgpkey.archlinux.org" = {
      server_type = "cx11"
      domain      = "openpgpkey"
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
  }

  # This creates gitlab pages varification entries.
  # Every line consists of "key" = "value":
  #   - key equals the pages subdomain
  #   - value equals the pages verification code
  #
  archlinux_org_gitlab_pages = {
    "conf"           = "60a06a1c02e42b36c3b4919f4d6de6bf"
    "whatcanwedofor" = "b5f8011047c1610ace52e754b568c834"
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
  # apollo = {
  #   ipv4_address = "138.201.81.199"
  #   ipv6_address = "2a01:4f8:172:1d86::1"
  #   ttl          = 600
  # }
  archlinux_org_a_aaaa = {
    apollo = {
      ipv4_address = "138.201.81.199"
      ipv6_address = "2a01:4f8:172:1d86::1"
    }
    aur4 = {
      ipv4_address = "5.9.250.164"
      ipv6_address = "2a01:4f8:160:3033::2"
    }
    dragon = {
      ipv4_address = "195.201.167.210"
      ipv6_address = "2a01:4f8:13a:102a::2"
    }
    gemini = {
      ipv4_address = "49.12.124.107"
      ipv6_address = "2a01:4f8:242:5614::2"
    }
    lists = {
      ipv4_address = "5.9.250.164"
      ipv6_address = "2a01:4f8:160:3033::2"
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
    archive                  = { value = "gemini" }
    dev                      = { value = "www" }
    g2kjxsblac7x             = { value = "gv-i5y6mnrelvpfiu.dv.googlehosted.com." }
    git                      = { value = "luna" }
    grafana                  = { value = "apollo" }
    ipxe                     = { value = "www" }
    "luna2._domainkey.aur"   = { value = "luna2._domainkey" }
    "luna2._domainkey.lists" = { value = "luna2._domainkey" }
    mailman                  = { value = "redirect" }
    packages                 = { value = "www" }
    planet                   = { value = "www" }
    projects                 = { value = "luna" }
    repos                    = { value = "gemini" }
    rsync                    = { value = "gemini" }
    sources                  = { value = "gemini" }
    "static.conf"            = { value = "redirect" }
    static                   = { value = "apollo" }
    status                   = { value = "stats.uptimerobot.com." }
    svn                      = { value = "gemini" }
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
      ipv4_address = "78.46.178.133"
      ipv6_address = "2a01:4f8:c2c:51e2::1"
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
      ipv4_address = "78.46.178.133"
      ipv6_address = "2a01:4f8:c2c:51e2::1"
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

resource "hetznerdns_record" "archlinux_org_origin_apollo_domainkey_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "apollo._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=rsa; s=email; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvZIf8SbjC53RDCbMjTEpo0FCuMSShlKWdwWjY1J+RpT3CL/21z4nXqVBYF1orkUScH8Nlabocraqk8lmpNBlKCUV77lk9mRsLkWhg+XjhvQXL1xfH8zAg1CntEZuaIMLUQ+5Gkw6BlO1qDRkmXS9UtV8Jt1rhjRtSrgN5lhztOCbQLRAtzKty/nMeClqsfT3nL2hbDeh+b/rYc\" \"l2veZAqiGcR2/0bnKlt+Nb5lOBY3oZiYLmZ5g+l9UXVjGUq9jGAooIWpQvuRPmin3RX31kXfr1A+mDBEexiOL1dDST2Zx7i9puXbqYH0u0IxBpweHCO5UqWx52mdXBuhs+DCo/JoZAHU/6eRzK+Sps50LgLFSzJJNfGXk5PUKdww2GHbkK3mCYfoFCpB0SADzl42+1w6YZk1yXoPdOHtChfQpCgjtddf1W8Q09pYO1/bn4l0erdFQsWb1K\" \"4wEVOCn+hHWbV42V+J3TyGxQ4AM8KQ1OPvUEabyTyqcO4evBaH7/S2wA91Z9QDjTbKmlNovs5zoxuOM/mPGPUuQMvhjoAP+rg4AwJ3Xwd3GgUcqQflcokayUYdp7F3aKp1NWAR9ibseU/XBYsSF8Ucjqzf4DJFUfrgjHUr97st7g4HUCyXrQO4tyE0ytiX8OFjjIszWLmF+B7Vup9O7k+dNz2Vj2Vyzkq1UCAwEAAQ==\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_lists_mx" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "lists"
  ttl     = 600
  value   = "10 luna"
  type    = "MX"
}

resource "hetznerdns_record" "archlinux_org_lists_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "lists"
  ttl     = 600
  # lists.archlinux.org
  value = "\"v=spf1 ip4:5.9.250.164 ip6:2a01:4f8:160:3033::2 ~all\""
  type  = "TXT"
}

resource "hetznerdns_record" "archlinux_org_luna_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=rsa; s=email; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvXrAPvtdX8Jrk4zmyk8w9T2zdAJGe7z0+4XHWWiuzH8Zse6S7oXiS9CVaPOsu0TZqHqhuclASU7qh0NXFwWyi2xRPyJOqH2Clu7vHS3j5F4TjURFOp4/EbA0iQu4rbItl4AU11z2pGSEj5SykUsrH+jjdqzNqAG9d4lNvkTs6RRzPF3KhhY+XljaeysEyDSS4ap4E0DYcduSIX\" \"oD1exFv4SEbXThD9PC1u81w4xusnmwmfHtR7aazeqPDP+S+FqDRy2woCaQb/VMbqMYVuWTVKJ2RxFyTKredOOV2c5kzih7GViwoetll/rTqO4aVbeir9K4f6YZg85dSQtVwEat7LV+zBnQwp3ivWkrIk8VEdSsCSaJlgattBiPHsfFFv1xw4qi3h+UvfCGgz35dtlnzd/noGhNARg0Z+kaMSTjy75V1mKx5sCH0o8nAX2XU8akJfLz58Vg\" \"kTx/sfealtwNA0gTy1t1jV8q0OF5RA0IeMRgCzeH2USOZI98W+EAUsGG5653Vzmp3FJRWp1tWJwRJ0M/aZ3ka/G1iTx3rNNcadVk+4q3gz3KnlAlun+m58y8pNWKjYuxmu9xkDRwM/33rv98j0R8HZO7HFL+1vjKkxSEuzmnTQ2O9F76/OsQoDPZ1Z6nJRvK8ts8PQr4ASKohby62+1F1M8U2Xn7u84dYLUCAwEAAQ==\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_luna2_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna2._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=rsa; s=email; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvXrAPvtdX8Jrk4zmyk8w9T2zdAJGe7z0+4XHWWiuzH8Zse6S7oXiS9CVaPOsu0TZqHqhuclASU7qh0NXFwWyi2xRPyJOqH2Clu7vHS3j5F4TjURFOp4/EbA0iQu4rbItl4AU11z2pGSEj5SykUsrH+jjdqzNqAG9d4lNvkTs6RRzPF3KhhY+XljaeysEyDSS4ap4E0DYcduSIX\" \"oD1exFv4SEbXThD9PC1u81w4xusnmwmfHtR7aazeqPDP+S+FqDRy2woCaQb/VMbqMYVuWTVKJ2RxFyTKredOOV2c5kzih7GViwoetll/rTqO4aVbeir9K4f6YZg85dSQtVwEat7LV+zBnQwp3ivWkrIk8VEdSsCSaJlgattBiPHsfFFv1xw4qi3h+UvfCGgz35dtlnzd/noGhNARg0Z+kaMSTjy75V1mKx5sCH0o8nAX2XU8akJfLz58Vg\" \"kTx/sfealtwNA0gTy1t1jV8q0OF5RA0IeMRgCzeH2USOZI98W+EAUsGG5653Vzmp3FJRWp1tWJwRJ0M/aZ3ka/G1iTx3rNNcadVk+4q3gz3KnlAlun+m58y8pNWKjYuxmu9xkDRwM/33rv98j0R8HZO7HFL+1vjKkxSEuzmnTQ2O9F76/OsQoDPZ1Z6nJRvK8ts8PQr4ASKohby62+1F1M8U2Xn7u84dYLUCAwEAAQ==\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_luna3_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna"
  ttl     = 600
  value   = "\"v=spf1 include:lists.archlinux.org -all\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_mtasts_cname" {
  for_each = toset(["", ".aur", ".master-key", ".lists"])

  zone_id = hetznerdns_zone.archlinux.id
  name    = "mta-sts${each.value}"
  value   = "mail"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org__mtasts_txt" {
  for_each = toset(["", ".aur", ".master-key", ".lists"])

  zone_id = hetznerdns_zone.archlinux.id
  name    = "_mta-sts${each.value}"
  ttl     = 600
  # date +%s
  value = "\"v=STSv1; id=1608210175\""
  type  = "TXT"
}

resource "hetznerdns_record" "archlinux_org_origin_mx" {
  for_each = toset(["@", "aur", "master-key"])

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.value
  ttl     = 600
  value   = "10 mail"
  type    = "MX"
}

resource "hetznerdns_record" "archlinux_org_origin_txt" {
  for_each = toset(["@", "aur", "mail", "master-key"])

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.value
  ttl     = 600
  # mail.archlinux.org
  value = "\"v=spf1 ip4:95.216.189.61 ip6:2a01:4f9:c010:3052::1 ~all\""
  type  = "TXT"
}

resource "hetznerdns_record" "archlinux_org_domainkey_dkim-ed25519_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "dkim-ed25519._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=ed25519; \" \"p=XOHB7b7V1puX+FryNIhsjXHYIFqk+q6JRu4XQ7Jc8MQ=\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_domainkey_dkim-rsa_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "dkim-rsa._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=rsa; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1GjGrEczq7iHZbvT7wa4ltJz2jwSndUGdRHgfEPnGBeevOXEAlEFr4zsdkfZEaNaQLIhZNpvKAt/A+kkyalkj4u9AnxqeNsNmZflFl6TKgvh0tWNEP3+XNxfdQ7zfml4WggL/YdAjXngg42oZEUsnS/6iozOFn7bNvzqBx5PFJ21pgyuR8DWyLaeOt+p55dVed7DCKnKi11Xjiu7k\" \"H68W8rose7g8Fv9fecBatEE4jwloOXsjh+tH0iab1NSSSpIq6EdgcPrpmrllN3/n2J/kCGK6ztISB6vR7xWgvgHSMjmEL0GPWzohGPrw2UQhZhrNV8dJpiLRYmfK+rXaKF0Kqag/F0e4C4jCKFX7NYFcYXYRlN5QlDFjZvUmOILlgnZ8w/SdZUKzpLObGuwnANLG+WSOjw42p9mXVGN6AfOQPu8OjRjS1MyhcdDIbUvZiQjbmiVJ5frpYZ39BTg\" \"CIzYLJJ5932+3gnwROu1OeljWkpBkfHZXPzADus80l3Vxsk91XZVB36rN8tyuMownR/M4HNC7ZE/EBwOnn1mGH7bLd6pva8u5Qy8Y6LrDdYea5Kk7aZ2WJSSRTV+nkPvOEIx+DfsIWNfmkVWzmuVky96fRvwOCuh38w8zpmlqzhDuGSQrBaLFXwAC7LYQ6kPDHzrjQhs99ScR0ix6YclrmpimMcCAwEAAQ==\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_dmarc_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "_dmarc"
  value   = "\"v=DMARC1; p=none; rua=mailto:dmarc-reports@archlinux.org; ruf=mailto:dmarc-reports@archlinux.org;\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_smtp_tlsrpt_txt" {
  for_each = toset(["", ".aur", ".master-key", ".lists"])

  zone_id = hetznerdns_zone.archlinux.id
  name    = "_smtp._tls${each.value}"
  value   = "\"v=TLSRPTv1;rua=mailto:postmaster@archlinux.org\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_matrix_tcp_srv" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "_matrix._tcp"
  value   = "10 0 8448 matrix"
  type    = "SRV"
}

resource "hetznerdns_record" "archlinux_org_github_challenge_archlinux" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "_github-challenge-archlinux"
  value   = "\"824af4446e\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_github_challenge_archlinux_www" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "_github-challenge-archlinux.www"
  value   = "\"b53f311f86\""
  type    = "TXT"
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

