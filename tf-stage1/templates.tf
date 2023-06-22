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

resource "hetznerdns_record" "archlinux_page_gitlab_pages_cname" {
  for_each = local.archlinux_page_gitlab_pages

  zone_id = hetznerdns_zone.archlinux_page.id
  name    = each.key
  value   = "pages.archlinux.org."
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_page_gitlab_pages_verification_code_txt" {
  for_each = local.archlinux_page_gitlab_pages

  zone_id = hetznerdns_zone.archlinux_page.id
  name    = "_gitlab-pages-verification-code.${each.key}"
  value   = "gitlab-pages-verification-code=${each.value}"
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_page_a" {
  for_each = local.archlinux_page_a_aaaa

  zone_id = hetznerdns_zone.archlinux_page.id
  name    = each.key
  ttl     = lookup(local.archlinux_page_a_aaaa[each.key], "ttl", null)
  value   = each.value.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_page_aaaa" {
  for_each = local.archlinux_page_a_aaaa

  zone_id = hetznerdns_zone.archlinux_page.id
  name    = each.key
  ttl     = lookup(local.archlinux_page_a_aaaa[each.key], "ttl", null)
  value   = each.value.ipv6_address
  type    = "AAAA"
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
  for_each = {
    for name, machine in local.machines : name => machine if try(machine.ipv4_enabled, true)
  }

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

resource "hcloud_primary_ip" "primary_ipv4" {
  for_each = {
    for name, machine in local.machines : name => machine if try(machine.ipv4_enabled, true)
  }

  name              = "ipv4-${each.key}"
  datacenter        = "fsn1-dc14"
  type              = "ipv4"
  assignee_type     = "server"
  auto_delete       = false
  delete_protection = true
  lifecycle {
    ignore_changes = [datacenter]
  }
}

resource "hcloud_primary_ip" "primary_ipv6" {
  for_each = local.machines

  name              = "ipv6-${each.key}"
  datacenter        = "fsn1-dc14"
  type              = "ipv6"
  assignee_type     = "server"
  auto_delete       = false
  delete_protection = true
  lifecycle {
    ignore_changes = [datacenter]
  }
}

resource "hcloud_server" "machine" {
  for_each = local.machines

  name               = each.key
  image              = data.hcloud_image.archlinux.id
  server_type        = each.value.server_type
  backups            = lookup(local.machines[each.key], "backups", false)
  keep_disk          = true
  datacenter         = "fsn1-dc14"
  delete_protection  = true
  rebuild_protection = true
  lifecycle {
    ignore_changes = [image, datacenter]
  }
  public_net {
    ipv4_enabled = try(each.value.ipv4_enabled, true)
    ipv6_enabled = true

    ipv4 = try(each.value.ipv4_enabled, true) ? hcloud_primary_ip.primary_ipv4[each.key].id : null
    ipv6 = hcloud_primary_ip.primary_ipv6[each.key].id
  }
}

resource "hetznerdns_record" "machine_a" {
  for_each = {
    for name, machine in local.machines : name => machine if can(machine.domain) && try(machine.ipv4_enabled, true)
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

resource "hetznerdns_record" "geo_ns1" {
  for_each = local.geo_domains

  zone_id = lookup(each.value, "zone", hetznerdns_zone.archlinux.id)
  name    = each.value.name
  value   = "america.mirror.pkgbuild.com."
  type    = "NS"
  ttl     = lookup(local.geo_domains[each.key], "ttl", 86400)
}

resource "hetznerdns_record" "geo_ns2" {
  for_each = local.geo_domains

  zone_id = lookup(each.value, "zone", hetznerdns_zone.archlinux.id)
  name    = each.value.name
  value   = "asia.mirror.pkgbuild.com."
  type    = "NS"
  ttl     = lookup(local.geo_domains[each.key], "ttl", 86400)
}

resource "hetznerdns_record" "geo_ns3" {
  for_each = local.geo_domains

  zone_id = lookup(each.value, "zone", hetznerdns_zone.archlinux.id)
  name    = each.value.name
  value   = "europe.mirror.pkgbuild.com."
  type    = "NS"
  ttl     = lookup(local.geo_domains[each.key], "ttl", 86400)
}

resource "hetznerdns_record" "geo_ns4" {
  for_each = local.geo_domains

  zone_id = lookup(each.value, "zone", hetznerdns_zone.archlinux.id)
  name    = each.value.name
  value   = "seoul.mirror.pkgbuild.com."
  type    = "NS"
  ttl     = lookup(local.geo_domains[each.key], "ttl", 86400)
}

resource "hetznerdns_record" "geo_ns5" {
  for_each = local.geo_domains

  zone_id = lookup(each.value, "zone", hetznerdns_zone.archlinux.id)
  name    = each.value.name
  value   = "sydney.mirror.pkgbuild.com."
  type    = "NS"
  ttl     = lookup(local.geo_domains[each.key], "ttl", 86400)
}

resource "hetznerdns_record" "geo_ns6" {
  for_each = local.geo_domains

  zone_id = lookup(each.value, "zone", hetznerdns_zone.archlinux.id)
  name    = each.value.name
  value   = "london.mirror.pkgbuild.com."
  type    = "NS"
  ttl     = lookup(local.geo_domains[each.key], "ttl", 86400)
}
