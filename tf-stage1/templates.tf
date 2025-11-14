# This files contains template handling for the main archlinux.tf file

resource "hcloud_zone_rrset" "archlinux_org_gitlab_pages_cname" {
  for_each = local.archlinux_org_gitlab_pages

  zone = hcloud_zone.archlinux_org.name
  name = each.key
  type = "CNAME"
  records = [
    { value = "pages.archlinux.org." },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_gitlab_pages_verification_code_txt" {
  for_each = local.archlinux_org_gitlab_pages

  zone = hcloud_zone.archlinux_org.name
  name = "_gitlab-pages-verification-code.${each.key}"
  type = "TXT"
  records = [
    { value = "\"gitlab-pages-verification-code=${each.value}\"" },
  ]
}

resource "hcloud_zone_rrset" "archlinux_page_gitlab_pages_cname" {
  for_each = local.archlinux_page_gitlab_pages

  zone = hcloud_zone.archlinux_page.name
  name = each.key
  type = "CNAME"
  records = [
    { value = "pages.archlinux.org." },
  ]
}

resource "hcloud_zone_rrset" "archlinux_page_gitlab_pages_verification_code_txt" {
  for_each = local.archlinux_page_gitlab_pages

  zone = hcloud_zone.archlinux_page.name
  name = "_gitlab-pages-verification-code.${each.key}"
  type = "TXT"
  records = [
    { value = "\"gitlab-pages-verification-code=${each.value}\"" },
  ]
}

resource "hcloud_zone_rrset" "archlinux_page_a" {
  for_each = local.archlinux_page_a_aaaa

  zone = hcloud_zone.archlinux_page.name
  name = each.key
  type = "A"
  ttl  = lookup(local.archlinux_page_a_aaaa[each.key], "ttl", null)
  records = [
    { value = each.value.ipv4_address },
  ]
}

resource "hcloud_zone_rrset" "archlinux_page_aaaa" {
  for_each = local.archlinux_page_a_aaaa

  zone = hcloud_zone.archlinux_page.name
  name = each.key
  type = "AAAA"
  ttl  = lookup(local.archlinux_page_a_aaaa[each.key], "ttl", null)
  records = [
    { value = each.value.ipv6_address },
  ]
}

resource "hcloud_zone_rrset" "pkgbuild_com_a" {
  for_each = {
    for k, v in local.pkgbuild_com_a_aaaa : k => v if try(v.ipv4_address != "", false)
  }

  zone = hcloud_zone.pkgbuild_com.name
  name = each.key
  type = "A"
  ttl  = lookup(local.pkgbuild_com_a_aaaa[each.key], "ttl", null)
  records = [
    { value = each.value.ipv4_address },
  ]
}

resource "hcloud_zone_rrset" "pkgbuild_com_aaaa" {
  for_each = local.pkgbuild_com_a_aaaa

  zone = hcloud_zone.pkgbuild_com.name
  name = each.key
  type = "AAAA"
  ttl  = lookup(local.pkgbuild_com_a_aaaa[each.key], "ttl", null)
  records = [
    { value = each.value.ipv6_address },
  ]
}

resource "hcloud_zone_rrset" "pkgbuild_org_https" {
  for_each = {
    for k, v in local.pkgbuild_com_a_aaaa : k => v if try(v.http3, false)
  }

  zone = hcloud_zone.pkgbuild_com.name
  name = each.key
  type = "HTTPS"
  ttl  = lookup(local.pkgbuild_com_a_aaaa[each.key], "ttl", null)
  records = [
    { value = "1 . alpn=h2,h3 ipv4hint=${each.value.ipv4_address} ipv6hint=${each.value.ipv6_address}" },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_txt" {
  for_each = local.archlinux_org_txt

  zone = hcloud_zone.archlinux_org.name
  name = each.key
  type = "TXT"
  ttl  = lookup(local.archlinux_org_txt[each.key], "ttl", null)
  records = [
    { value = "\"${each.value.value}\"" },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_mx" {
  for_each = local.archlinux_org_mx

  zone = hcloud_zone.archlinux_org.name
  name = each.key
  type = "MX"
  ttl  = lookup(local.archlinux_org_mx[each.key], "ttl", null)
  records = [
    { value = "10 ${each.value.mx}" },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_a" {
  for_each = local.archlinux_org_a_aaaa

  zone = hcloud_zone.archlinux_org.name
  name = each.key
  type = "A"
  ttl  = lookup(local.archlinux_org_a_aaaa[each.key], "ttl", null)
  records = [
    { value = each.value.ipv4_address },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_aaaa" {
  for_each = local.archlinux_org_a_aaaa

  zone = hcloud_zone.archlinux_org.name
  name = each.key
  type = "AAAA"
  ttl  = lookup(local.archlinux_org_a_aaaa[each.key], "ttl", null)
  records = [
    { value = each.value.ipv6_address },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_https" {
  for_each = {
    for k, v in local.archlinux_org_a_aaaa : k => v if try(v.http3, false)
  }

  zone = hcloud_zone.archlinux_org.name
  name = each.key
  type = "HTTPS"
  ttl  = lookup(local.archlinux_org_a_aaaa[each.key], "ttl", null)
  records = [
    { value = "1 . alpn=h2,h3 ipv4hint=${each.value.ipv4_address} ipv6hint=${each.value.ipv6_address}" },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_cname" {
  for_each = local.archlinux_org_cname

  zone = hcloud_zone.archlinux_org.name
  name = each.key
  type = "CNAME"
  ttl  = lookup(local.archlinux_org_cname[each.key], "ttl", null)
  records = [
    { value = each.value.value },
  ]
}

resource "hcloud_rdns" "rdns_ipv4" {
  for_each = {
    for name, machine in local.machines : name => machine if can(machine.domain) && try(machine.ipv4_enabled, true)
  }

  server_id  = hcloud_server.machine[each.key].id
  ip_address = hcloud_server.machine[each.key].ipv4_address
  dns_ptr    = each.key
}

resource "hcloud_rdns" "rdns_ipv6" {
  for_each = {
    for name, machine in local.machines : name => machine if can(machine.domain)
  }

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

resource "hcloud_zone_rrset" "machine_a" {
  for_each = {
    for name, machine in local.machines : name => machine if can(machine.domain) && try(machine.ipv4_enabled, true)
  }

  zone = lookup(local.machines[each.key], "zone", hcloud_zone.archlinux_org.name)
  name = each.value.domain
  type = "A"
  ttl  = lookup(local.machines[each.key], "ttl", null)
  records = [
    { value = hcloud_server.machine[each.key].ipv4_address },
  ]
}

resource "hcloud_zone_rrset" "machine_aaaa" {
  for_each = {
    for name, machine in local.machines : name => machine if can(machine.domain)
  }

  zone = lookup(local.machines[each.key], "zone", hcloud_zone.archlinux_org.name)
  name = each.value.domain
  type = "AAAA"
  ttl  = lookup(local.machines[each.key], "ttl", null)
  records = [
    { value = hcloud_server.machine[each.key].ipv6_address },
  ]
}

resource "hcloud_zone_rrset" "machine_https" {
  for_each = {
    for name, machine in local.machines : name => machine if can(machine.domain) && try(machine.http3, false)
  }

  zone = lookup(local.machines[each.key], "zone", hcloud_zone.archlinux_org.name)
  name = each.value.domain
  type = "HTTPS"
  ttl  = lookup(local.machines[each.key], "ttl", null)
  records = [
    { value = (try(local.machines[each.key].ipv4_enabled, true) ?
      "1 . alpn=h2,h3 ipv4hint=${hcloud_server.machine[each.key].ipv4_address} ipv6hint=${hcloud_server.machine[each.key].ipv6_address}" :
      "1 . alpn=h2,h3 ipv6hint=${hcloud_server.machine[each.key].ipv6_address}")
    },
  ]
}

resource "hcloud_zone_rrset" "geo_ns" {
  for_each = local.geo_domains

  zone = lookup(each.value, "zone", hcloud_zone.archlinux_org.name)
  name = each.value.name
  type = "NS"
  ttl  = lookup(local.geo_domains[each.key], "ttl", 86400)
  records = [
    { value = "europe.mirror.pkgbuild.com." },
    { value = "sydney.mirror.pkgbuild.com." },
    { value = "london.mirror.pkgbuild.com." }
    { value = "umea.mirror.pkgbuild.com." }
  ]
}
