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

resource "hetznerdns_zone" "archlinux" {
  name = "archlinux.org"
  ttl  = 86400
}

resource "hetznerdns_zone" "pkgbuild" {
  name = "pkgbuild.com"
  ttl  = 86400
}

resource "hetznerdns_record" "pkgbuild_com_origin_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "78.46.178.133"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_origin_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "2a01:4f8:c2c:51e2::1"
  type    = "AAAA"
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

resource "hetznerdns_record" "pkgbuild_com_wildcard_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "*"
  value   = "78.46.178.133"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_wildcard_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "*"
  value   = "2a01:4f8:c2c:51e2::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_mirror_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "mirror"
  value   = "78.46.209.220"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_mirror_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "mirror"
  value   = "2a01:4f8:c2c:c62f::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_repro3_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "repro3"
  value   = "147.75.81.79"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_repro3_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "repro3"
  value   = "2604:1380:2001:4500::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_www_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "www"
  value   = "78.46.178.133"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_www_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "www"
  value   = "2a01:4f8:c2c:51e2::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_origin_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "138.201.81.199"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_origin_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "2a01:4f8:172:1d86::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_origin_caa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "0 issue \"letsencrypt.org\""
  type    = "CAA"
}

resource "hetznerdns_record" "archlinux_org_origin_mx" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  ttl     = 600
  value   = "10 mail"
  type    = "MX"
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

resource "hetznerdns_record" "archlinux_org_accounts_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "accounts"
  value   = hcloud_server.accounts.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_accounts_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "accounts"
  value   = hcloud_server.accounts.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_apollo_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "apollo"
  ttl     = 600
  value   = "138.201.81.199"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_apollo_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "apollo"
  ttl     = 600
  value   = "2a01:4f8:172:1d86::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_archive_gemini_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "archive.gemini"
  value   = "49.12.124.107"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_aur_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur"
  value   = hcloud_server.aur.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_aur_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur"
  value   = hcloud_server.aur.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_aur_mx" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur"
  ttl     = 600
  value   = "10 mail"
  type    = "MX"
}

resource "hetznerdns_record" "archlinux_org_aur_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur"
  ttl     = 600
  value   = "\"v=spf1 a ?all\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_aur_dev_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur-dev"
  value   = hcloud_server.aur-dev.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_aur_dev_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur-dev"
  value   = hcloud_server.aur-dev.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_aur4_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur4"
  value   = "5.9.250.164"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_aur4_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur4"
  value   = "2a01:4f8:160:3033::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_bbs_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "bbs"
  value   = hcloud_server.bbs.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_bbs_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "bbs"
  value   = hcloud_server.bbs.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_bugs_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "bugs"
  value   = hcloud_server.bugs.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_bugs_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "bugs"
  value   = hcloud_server.bugs.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_dragon_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "dragon"
  value   = "195.201.167.210"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_dragon_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "dragon"
  value   = "2a01:4f8:13a:102a::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_gemini_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "gemini"
  value   = "49.12.124.107"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_gemini_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "gemini"
  value   = "2a01:4f8:242:5614::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_gitlab_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "gitlab"
  value   = hcloud_server.gitlab.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_gitlab_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "gitlab"
  value   = hcloud_server.gitlab.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_homedir_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "homedir"
  value   = hcloud_server.homedir.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_homedir_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "homedir"
  value   = hcloud_server.homedir.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_lists_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "lists"
  value   = "5.9.250.164"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_lists_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "lists"
  value   = "2a01:4f8:160:3033::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_lists_mx" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "lists"
  ttl     = 600
  value   = "10 luna"
  type    = "MX"
}

resource "hetznerdns_record" "archlinux_org_luna_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna"
  ttl     = 600
  value   = "5.9.250.164"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_luna_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna"
  ttl     = 600
  value   = "2a01:4f8:160:3033::2"
  type    = "AAAA"
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

resource "hetznerdns_record" "archlinux_org_mailman3_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "mailman3"
  value   = hcloud_server.mailman3.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_master_key_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "master-key"
  value   = "138.201.81.199"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_master_key_mx" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "master-key"
  ttl     = 600
  value   = "10 mail"
  type    = "MX"
}

resource "hetznerdns_record" "archlinux_org_matrix_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "matrix"
  value   = hcloud_server.matrix.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_monitoring_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "monitoring"
  value   = hcloud_server.monitoring.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_monitoring_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "monitoring"
  value   = hcloud_server.monitoring.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_mail_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "mail"
  ttl     = 600
  value   = "95.216.189.61"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_mail_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "mail"
  ttl     = 600
  value   = "2a01:4f9:c010:3052::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_origin_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  ttl     = 600
  value   = "\"v=spf1 ip4:66.211.214.132/28 ip4:5.9.250.164 ip6:2a01:4f8:160:3033::2 ip4:138.201.81.199/32 ip4:88.198.91.70/32 ip4:95.216.189.61 ip6:2a01:4f9:c010:3052::1 a:aur.archlinux.org a:apollo.archlinux.org ~all\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_mail_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "mail"
  ttl     = 600
  value   = "\"v=spf1 include:archlinux.org -all\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_domainkey_mail_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "mail._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=rsa; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwq23VERpAp07Xe9vTro38q7D8HzGSi4I+vS2ZWdGeGmr9/YQs6EmoiDUWdXbThCAPhSW6RLgG62XLxnjEj9LxwyeluHKI4eMq14shwcTeRNzyrz/bTqAQouVLe3PmUo6mHWJfd4Z7k7/Kv0nmEx9cqM+IIwOjsGN28e52OCvc7NZeRqEvAJtlsV1Ren0piFvw/cuOqzo3Xgk2O\" \"T1/6PoItIQm1AYTmDBjPHvUqSa/lyr6MQYpH2EeQa7HV0l+XZmYA/tRpUE9ixwZ7+mvixMumTDRMB7Pp+WqbqXQcDodrh0H5RzxBPv11KP+09qcCZo26iBZeRb9H0CU0glIFJLWIejBY/10mOtcs68Kop2rNz3mga/Pxj9JGWndkjmLSscyPjjySHy/kakAqSafijq74ysA8nKx+MRnZYzqAwtn8sk8MF80mTZuMvHgzUn7fbG2bxVF7hc\" \"nD80OjlD+gXrl1MmiO5QfGPhsnx9SI/Bp3vo5rLayBTRCWv7QsQeU2hWi0wC/l2aG50apdPG0FJdrIQHicjx5zW+fWISbHRE3VwCI1oVejnl1E6XYmcrgeWG8O+iukfPYzEWiJ5BY8uk3bO75dFqaFH0yU7hdsC+yk+9+ZQDZKHcc0jum7C3U8SdW27af8/DkjAyoDn0g0Cj6N2QWDbZmHJfD7tY6O6Qpm8CAwEAAQ==\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_dmarc_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "_dmarc"
  value   = "\"v=DMARC1; p=none; rua=mailto:dmarc-reports@archlinux.org; ruf=mailto:dmarc-reports@archlinux.org;\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_openpgpkey_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "openpgpkey"
  value   = hcloud_server.openpgpkey.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_openpgpkey_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "openpgpkey"
  value   = hcloud_server.openpgpkey.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_phrik_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "phrik"
  value   = hcloud_server.phrik.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_quassel_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "quassel"
  value   = hcloud_server.quassel.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_quassel_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "quassel"
  value   = hcloud_server.quassel.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_reproducible_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "reproducible"
  value   = hcloud_server.reproducible.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_runner2_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "runner2"
  value   = "147.75.80.217"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_runner2_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "runner2"
  value   = "2604:1380:2001:4500::3"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_secure_runner1_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "secure-runner1"
  value   = "116.202.134.150"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_secure_runner1_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "secure-runner1"
  value   = "2a01:4f8:231:4e1e::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_svn2gittest_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "svn2gittest"
  value   = hcloud_server.svn2gittest.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_svn2gittest_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "svn2gittest"
  value   = hcloud_server.svn2gittest.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_state_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "state"
  value   = "116.203.16.252"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_state_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "state"
  value   = "2a01:4f8:c2c:474::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_archive_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "archive"
  value   = "gemini"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_conf_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "conf"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_dev_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "dev"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_g2kjxsblac7x_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "g2kjxsblac7x"
  value   = "gv-i5y6mnrelvpfiu.dv.googlehosted.com."
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_git_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "git"
  value   = "luna"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_grafana_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "grafana"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_ipxe_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "ipxe"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_luna2_domainkey_aur_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna2._domainkey.aur"
  value   = "luna2._domainkey"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_luna2_domainkey_lists_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna2._domainkey.lists"
  value   = "luna2._domainkey"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_mailman_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "mailman"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_packages_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "packages"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_patchwork_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "patchwork"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_planet_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "planet"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_projects_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "projects"
  value   = "luna"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_repos_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "repos"
  value   = "gemini"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_rsync_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "rsync"
  value   = "gemini"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_security_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "security"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_sources_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "sources"
  value   = "gemini"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_static_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "static"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_static_conf_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "static.conf"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_status_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "status"
  value   = "stats.uptimerobot.com."
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_svn_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "svn"
  value   = "gemini"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_wiki_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "wiki"
  value   = "apollo"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_www_cname" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "www"
  value   = "apollo"
  type    = "CNAME"
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

resource "hcloud_rdns" "quassel_ipv4" {
  server_id  = hcloud_server.quassel.id
  ip_address = hcloud_server.quassel.ipv4_address
  dns_ptr    = "quassel.archlinux.org"
}

resource "hcloud_rdns" "quassel_ipv6" {
  server_id  = hcloud_server.quassel.id
  ip_address = hcloud_server.quassel.ipv6_address
  dns_ptr    = "quassel.archlinux.org"
}

resource "hcloud_server" "quassel" {
  name        = "quassel.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "phrik_ipv4" {
  server_id  = hcloud_server.phrik.id
  ip_address = hcloud_server.phrik.ipv4_address
  dns_ptr    = "phrik.archlinux.org"
}

resource "hcloud_rdns" "phrik_ipv6" {
  server_id  = hcloud_server.phrik.id
  ip_address = hcloud_server.phrik.ipv6_address
  dns_ptr    = "phrik.archlinux.org"
}

resource "hcloud_server" "phrik" {
  name        = "phrik.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "bbs_ipv4" {
  server_id  = hcloud_server.bbs.id
  ip_address = hcloud_server.bbs.ipv4_address
  dns_ptr    = "bbs.archlinux.org"
}

resource "hcloud_rdns" "bbs_ipv6" {
  server_id  = hcloud_server.bbs.id
  ip_address = hcloud_server.bbs.ipv6_address
  dns_ptr    = "bbs.archlinux.org"
}

resource "hcloud_server" "bbs" {
  name        = "bbs.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx21"
  lifecycle {
    ignore_changes = [image]
  }
}


resource "hcloud_rdns" "gitlab_ipv4" {
  server_id  = hcloud_server.gitlab.id
  ip_address = hcloud_server.gitlab.ipv4_address
  dns_ptr    = "gitlab.archlinux.org"
}

resource "hcloud_rdns" "gitlab_ipv6" {
  server_id  = hcloud_server.gitlab.id
  ip_address = hcloud_server.gitlab.ipv6_address
  dns_ptr    = "gitlab.archlinux.org"
}

resource "hcloud_server" "gitlab" {
  name        = "gitlab.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx51"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_volume" "gitlab" {
  name      = "gitlab"
  size      = 1000
  server_id = hcloud_server.gitlab.id
}


resource "hcloud_rdns" "matrix_ipv4" {
  server_id  = hcloud_server.matrix.id
  ip_address = hcloud_server.matrix.ipv4_address
  dns_ptr    = "matrix.archlinux.org"
}

resource "hcloud_rdns" "matrix_ipv6" {
  server_id  = hcloud_server.matrix.id
  ip_address = hcloud_server.matrix.ipv6_address
  dns_ptr    = "matrix.archlinux.org"
}

resource "hcloud_server" "matrix" {
  name        = "matrix.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cpx31"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "acccounts_ipv4" {
  server_id  = hcloud_server.accounts.id
  ip_address = hcloud_server.accounts.ipv4_address
  dns_ptr    = "accounts.archlinux.org"
}

resource "hcloud_rdns" "acccounts_ipv6" {
  server_id  = hcloud_server.accounts.id
  ip_address = hcloud_server.accounts.ipv6_address
  dns_ptr    = "accounts.archlinux.org"
}

resource "hcloud_server" "accounts" {
  name        = "accounts.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  provisioner "local-exec" {
    working_dir = ".."
    command     = "ansible-playbook --ssh-extra-args '-o StrictHostKeyChecking=no' playbooks/accounts.archlinux.org.yml"
  }
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_volume" "mirror" {
  name      = "mirror"
  size      = 100
  server_id = hcloud_server.mirror.id
}

resource "hcloud_rdns" "mirror_ipv4" {
  server_id  = hcloud_server.mirror.id
  ip_address = hcloud_server.mirror.ipv4_address
  dns_ptr    = "mirror.pkgbuild.com"
}

resource "hcloud_rdns" "mirror_ipv6" {
  server_id  = hcloud_server.mirror.id
  ip_address = hcloud_server.mirror.ipv6_address
  dns_ptr    = "mirror.pkgbuild.com"
}

resource "hcloud_server" "mirror" {
  name        = "mirror.pkgbuild.com"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}


resource "hcloud_rdns" "homedir_ipv4" {
  server_id  = hcloud_server.homedir.id
  ip_address = hcloud_server.homedir.ipv4_address
  dns_ptr    = "homedir.archlinux.org"
}

resource "hcloud_rdns" "homedir_ipv6" {
  server_id  = hcloud_server.homedir.id
  ip_address = hcloud_server.homedir.ipv6_address
  dns_ptr    = "homedir.archlinux.org"
}

resource "hcloud_server" "homedir" {
  name        = "homedir.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_volume" "homedir" {
  name      = "homedir"
  size      = 100
  server_id = hcloud_server.homedir.id
}

resource "hcloud_rdns" "bugs_ipv4" {
  server_id  = hcloud_server.bugs.id
  ip_address = hcloud_server.bugs.ipv4_address
  dns_ptr    = "bugs.archlinux.org"
}

resource "hcloud_rdns" "bugs_ipv6" {
  server_id  = hcloud_server.bugs.id
  ip_address = hcloud_server.bugs.ipv6_address
  dns_ptr    = "bugs.archlinux.org"
}

resource "hcloud_server" "bugs" {
  name        = "bugs.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "aur_ipv4" {
  server_id  = hcloud_server.aur.id
  ip_address = hcloud_server.aur.ipv4_address
  dns_ptr    = "aur.archlinux.org"
}

resource "hcloud_rdns" "aur_ipv6" {
  server_id  = hcloud_server.aur.id
  ip_address = hcloud_server.aur.ipv6_address
  dns_ptr    = "aur.archlinux.org"
}

resource "hcloud_server" "aur" {
  name        = "aur.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cpx41"
  keep_disk   = true
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "aur-dev_ipv4" {
  server_id  = hcloud_server.aur-dev.id
  ip_address = hcloud_server.aur-dev.ipv4_address
  dns_ptr    = "aur-dev.archlinux.org"
}

resource "hcloud_rdns" "aur-dev_ipv6" {
  server_id  = hcloud_server.aur-dev.id
  ip_address = hcloud_server.aur-dev.ipv6_address
  dns_ptr    = "aur-dev.archlinux.org"
}

resource "hcloud_server" "aur-dev" {
  name        = "aur-dev.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "mailman3_ipv4" {
  server_id  = hcloud_server.mailman3.id
  ip_address = hcloud_server.mailman3.ipv4_address
  dns_ptr    = "mailman3.archlinux.org"
}

resource "hcloud_rdns" "mailman3_ipv6" {
  server_id  = hcloud_server.mailman3.id
  ip_address = hcloud_server.mailman3.ipv6_address
  dns_ptr    = "mailman3.archlinux.org"
}

resource "hcloud_server" "mailman3" {
  name        = "mailman3.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "reproducible_ipv4" {
  server_id  = hcloud_server.reproducible.id
  ip_address = hcloud_server.reproducible.ipv4_address
  dns_ptr    = "reproducible.archlinux.org"
}

resource "hcloud_rdns" "reproducible_ipv6" {
  server_id  = hcloud_server.reproducible.id
  ip_address = hcloud_server.reproducible.ipv6_address
  dns_ptr    = "reproducible.archlinux.org"
}

resource "hcloud_server" "reproducible" {
  name        = "reproducible.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "monitoring_ipv4" {
  server_id  = hcloud_server.monitoring.id
  ip_address = hcloud_server.monitoring.ipv4_address
  dns_ptr    = "monitoring.archlinux.org"
}

resource "hcloud_rdns" "monitoring_ipv6" {
  server_id  = hcloud_server.monitoring.id
  ip_address = hcloud_server.monitoring.ipv6_address
  dns_ptr    = "monitoring.archlinux.org"
}

resource "hcloud_server" "monitoring" {
  name        = "monitoring.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "svn2gittest_ipv4" {
  server_id  = hcloud_server.svn2gittest.id
  ip_address = hcloud_server.svn2gittest.ipv4_address
  dns_ptr    = "svn2gittest.archlinux.org"
}

resource "hcloud_rdns" "svn2gittest_ipv6" {
  server_id  = hcloud_server.svn2gittest.id
  ip_address = hcloud_server.svn2gittest.ipv6_address
  dns_ptr    = "svn2gittest.archlinux.org"
}

resource "hcloud_server" "svn2gittest" {
  name        = "svn2gittest"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "mail_ipv4" {
  server_id  = hcloud_server.mail.id
  ip_address = hcloud_server.mail.ipv4_address
  dns_ptr    = "mail.archlinux.org"
}

resource "hcloud_rdns" "mail_ipv6" {
  server_id  = hcloud_server.mail.id
  ip_address = hcloud_server.mail.ipv6_address
  dns_ptr    = "mail.archlinux.org"
}

resource "hcloud_server" "mail" {
  name        = "mail.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "openpgpkey_ipv4" {
  server_id  = hcloud_server.openpgpkey.id
  ip_address = hcloud_server.openpgpkey.ipv4_address
  dns_ptr    = "openpgpkey.archlinux.org"
}

resource "hcloud_rdns" "openpgpkey_ipv6" {
  server_id  = hcloud_server.openpgpkey.id
  ip_address = hcloud_server.openpgpkey.ipv6_address
  dns_ptr    = "openpgpkey.archlinux.org"
}

resource "hcloud_server" "openpgpkey" {
  name        = "openpgpkey.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}
