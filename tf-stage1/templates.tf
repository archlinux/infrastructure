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
  value   = "\"${each.value.value}\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_mx" {
  for_each = local.archlinux_org_mx

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.key
  ttl     = lookup(local.archlinux_org_mx[each.key], "ttl", null)
  value   = "10 ${each.value.mx}"
  type    = "MX"
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

  name               = each.key
  image              = data.hcloud_image.archlinux.id
  server_type        = each.value.server_type
  keep_disk          = true
  location           = "fsn1"
  delete_protection  = true
  rebuild_protection = true
  lifecycle {
    ignore_changes = [image, location]
  }
}

resource "hetznerdns_record" "machine_a" {
  for_each = {
    for name, machine in local.machines : name => machine if can(machine.domain)
  }

  zone_id = lookup(local.machines[each.key], "zone", hetznerdns_zone.archlinux.id)
  name    = each.value.domain
  ttl     = lookup(local.machines[each.key], "ttl", null)
  value   = hcloud_server.machine[each.key].ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "machine_aaaa" {
  for_each = {
    for name, machine in local.machines : name => machine if can(machine.domain)
  }

  zone_id = lookup(local.machines[each.key], "zone", hetznerdns_zone.archlinux.id)
  name    = each.value.domain
  ttl     = lookup(local.machines[each.key], "ttl", null)
  value   = hcloud_server.machine[each.key].ipv6_address
  type    = "AAAA"
}
