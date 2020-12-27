# This files contains template handling for the main archlinux.tf file

resource "hetznerdns_record" "archlinux_org_gitlab_pages_cname" {
  for_each = local.archlinux_org_gitlab_pages

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.key
  value   = "pages.archlinux.org."
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_gitlab_pages_verification_code_txt" {
  for_each = local.archlinux_org_gitlab_pages

  zone_id = hetznerdns_zone.archlinux.id
  name    = "_gitlab-pages-verification-code.${each.key}"
  value   = "gitlab-pages-verification-code=${each.value}"
  type    = "TXT"
}

resource "hetznerdns_record" "pkgbuild_org_a" {
  for_each = local.pkgbuild_com_a_aaaa

  zone_id = hetznerdns_zone.pkgbuild.id
  name    = each.key
  ttl     = lookup(local.pkgbuild_com_a_aaaa[each.key], "ttl", null)
  value   = each.value.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_org_aaaa" {
  for_each = local.pkgbuild_com_a_aaaa

  zone_id = hetznerdns_zone.pkgbuild.id
  name    = each.key
  ttl     = lookup(local.pkgbuild_com_a_aaaa[each.key], "ttl", null)
  value   = each.value.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_txt" {
  for_each = local.archlinux_org_txt

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.key
  ttl     = lookup(local.archlinux_org_txt[each.key], "ttl", null)
  value   = "\"${each.value.value}\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_mtasts_cname" {
  for_each = local.archlinux_org_mail

  zone_id = hetznerdns_zone.archlinux.id
  name    = "_mta-sts${each.key == "@" ? "" : ".${each.key}"}"
  value   = "mail"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org__mtasts_txt" {
  for_each = local.archlinux_org_mail

  zone_id = hetznerdns_zone.archlinux.id
  name    = "_mta-sts${each.key == "@" ? "" : ".${each.key}"}"
  ttl     = 600
  value   = "\"v=STSv1; id=${local.archlinux_org_mtssts_policy_id}\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_smtp_tlsrpt_txt" {
  for_each = local.archlinux_org_mail

  zone_id = hetznerdns_zone.archlinux.id
  name    = "_smtp._tls${each.key == "@" ? "" : ".${each.key}"}"
  value   = "\"v=TLSRPTv1;rua=mailto:postmaster@archlinux.org\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_mx" {
  for_each = local.archlinux_org_mail

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.key
  ttl     = 600
  value   = "10 ${each.value.mx}"
  type    = "MX"
}

resource "hetznerdns_record" "archlinux_org_mail_txt" {
  for_each = local.archlinux_org_mail

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.key
  ttl     = 600
  value   = local.archlinux_org_txt[each.value.mx].value
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_a" {
  for_each = local.archlinux_org_a_aaaa

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.key
  ttl     = lookup(local.archlinux_org_a_aaaa[each.key], "ttl", null)
  value   = each.value.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_aaaa" {
  for_each = local.archlinux_org_a_aaaa

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.key
  ttl     = lookup(local.archlinux_org_a_aaaa[each.key], "ttl", null)
  value   = each.value.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_cname" {
  for_each = local.archlinux_org_cname

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.key
  ttl     = lookup(local.archlinux_org_cname[each.key], "ttl", null)
  value   = each.value.value
  type    = "CNAME"
}

resource "hcloud_rdns" "rdns_ipv4" {
  for_each = local.machines

  server_id  = hcloud_server.machine[each.key].id
  ip_address = hcloud_server.machine[each.key].ipv4_address
  dns_ptr    = each.key
}

resource "hcloud_rdns" "rdns_ipv6" {
  for_each = local.machines

  server_id  = hcloud_server.machine[each.key].id
  ip_address = hcloud_server.machine[each.key].ipv6_address
  dns_ptr    = each.key
}

resource "hcloud_server" "machine" {
  for_each = local.machines

  name        = each.key
  image       = data.hcloud_image.archlinux.id
  server_type = each.value.server_type
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hetznerdns_record" "machine_a" {
  for_each = local.machines

  zone_id = lookup(local.machines[each.key], "zone", hetznerdns_zone.archlinux.id)
  name    = each.value.domain
  ttl     = lookup(local.machines[each.key], "ttl", null)
  value   = hcloud_server.machine[each.key].ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "machine_aaaa" {
  for_each = local.machines

  zone_id = lookup(local.machines[each.key], "zone", hetznerdns_zone.archlinux.id)
  name    = each.value.domain
  ttl     = lookup(local.machines[each.key], "ttl", null)
  value   = hcloud_server.machine[each.key].ipv6_address
  type    = "AAAA"
}
