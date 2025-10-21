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

data "external" "vault_hetzner_s3" {
  program = [
    "${path.module}/../misc/get_key.py", "${path.module}/../group_vars/all/vault_hetzner_s3.yml",
    "vault_hetzner_s3_gitlab_runners_access_key",
    "vault_hetzner_s3_gitlab_runners_secret_key",
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

provider "minio" {
  minio_server   = "fsn1.your-objectstorage.com"
  minio_user     = data.external.vault_hetzner_s3.result.vault_hetzner_s3_gitlab_runners_access_key
  minio_password = data.external.vault_hetzner_s3.result.vault_hetzner_s3_gitlab_runners_secret_key
  minio_region   = "fsn1"
  minio_ssl      = true
}

resource "minio_s3_bucket" "gitlab_runners_cache" {
  bucket         = "archlinux-gitlab-runners-cache"
  acl            = "private"
  object_locking = false
}

resource "minio_ilm_policy" "gitlab_runners_cache_expiry" {
  bucket = minio_s3_bucket.gitlab_runners_cache.bucket

  rule {
    id         = "expire-14d"
    status     = "Enabled"
    expiration = "14d"
  }
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
  #   - ipv4_enabled (optional, set to false to create an IPv6-only server)
  #   - location (optional, defaults to 'fsn1')
  #   - floating_ipv4 (optional, creates an additional ipv4 floating address for the server)
  #   - floating_ipv6 (optional, creates an additional ipv6 floating address for the server)
  #
  # Example:
  # "archlinux.org" = {
  #   server_type = "cx23"
  #   domain      = "@"
  #   ttl         = 3600
  # }
  machines = {
    "accounts.archlinux.org" = {
      server_type = "cx23"
      domain      = "accounts"
      location    = "hel1"
    }
    "archlinux.org" = {
      server_type = "cpx32"
      # reserve IPv6 address as static target for the HAproxy ADN service
      floating_ipv6 = true
      location      = "hel1"
    }
    "aur.archlinux.org" = {
      server_type = "cpx52"
      # reserve IPv6 address as static target for the HAproxy ADN service
      floating_ipv6 = true
      location      = "hel1"
    }
    "bastion.archlinux.org" = {
      server_type = "cx23"
      domain      = "bastion"
    }
    "bbs.archlinux.org" = {
      server_type   = "cx23"
      domain        = "bbs"
      ttl           = 60
      floating_ipv6 = true
      location      = "nbg1"
    }
    "buildbtw.dev.archlinux.org" = {
      server_type = "cx23"
      domain      = "buildbtw.dev"
      http3       = true
    }
    "buildbtw.staging.archlinux.org" = {
      server_type = "cx23"
      domain      = "buildbtw.staging"
      http3       = true
    }
    "buildbtw.archlinux.org" = {
      server_type = "cx23"
      domain      = "buildbtw"
      http3       = true
    }
    "bugbuddy.archlinux.org" = {
      server_type = "cx23"
      domain      = "bugbuddy"
    }
    "bumpbuddy.archlinux.org" = {
      server_type = "cx23"
      domain      = "bumpbuddy"
    }
    "dashboards.archlinux.org" = {
      server_type = "cx23"
      domain      = "dashboards"
    }
    "debuginfod.archlinux.org" = {
      server_type = "cx33"
      domain      = "debuginfod"
    }
    "discourse.sandbox.archlinux.org" = {
      server_type = "cx33"
      domain      = "discourse.sandbox"
    }
    "gluebuddy.archlinux.org" = {
      server_type = "cx23"
      domain      = "gluebuddy"
    }
    "homedir.archlinux.org" = {
      server_type = "cx23"
      domain      = "homedir"
      location    = "nbg1"
    }
    "lists.archlinux.org" = {
      server_type = "cx23"
      domain      = "lists"
      location    = "hel1"
    }
    "mail.archlinux.org" = {
      server_type = "cx23"
      domain      = "mail"
      location    = "hel1"
    }
    "man.archlinux.org" = {
      server_type = "cx23"
      location    = "hel1"
    }
    "matrix.archlinux.org" = {
      server_type = "cpx32"
      domain      = "matrix"
      location    = "nbg1"
    }
    "md.archlinux.org" = {
      server_type = "cx23"
      domain      = "md"
      location    = "hel1"
    }
    "mirror.pkgbuild.com" = {
      server_type = "cx33"
      domain      = "mirror"
      zone        = hcloud_zone.pkgbuild_com.id
      http3       = true
      location    = "nbg1"
    }
    "monitoring.archlinux.org" = {
      server_type = "cpx32"
      domain      = "monitoring"
      location    = "hel1"
    }
    "mumble.archlinux.org" = {
      server_type = "cx23"
      domain      = "mumble"
    }
    "opensearch.archlinux.org" = {
      server_type = "cx23"
      domain      = "opensearch"
    }
    "phrik.archlinux.org" = {
      server_type = "cx23"
      domain      = "phrik"
      location    = "nbg1"
    }
    "quassel.archlinux.org" = {
      server_type = "cx23"
      domain      = "quassel"
      location    = "nbg1"
    }
    "redirect.archlinux.org" = {
      server_type = "cx23"
      domain      = "redirect"
      location    = "hel1"
    }
    "reproducible.archlinux.org" = {
      server_type = "cx23"
      domain      = "reproducible"
      location    = "hel1"
    }
    "security.archlinux.org" = {
      server_type = "cx23"
      domain      = "security"
      location    = "hel1"
    }
    "state.archlinux.org" = {
      server_type = "cx23"
      domain      = "state"
      backups     = true
      location    = "nbg1"
    }
    "test.pkgbuild.com" = {
      server_type = "cx23"
    }
    "wiki.archlinux.org" = {
      server_type = "cpx52"
      # reserve IPv6 address as static target for the HAproxy ADN service
      floating_ipv6 = true
      location      = "hel1"
    }
  }

  # This creates gitlab pages verification entries.
  # Every line consists of "key" = "value":
  #   - key equals the pages subdomain
  #   - value equals the pages verification code
  #
  archlinux_org_gitlab_pages = {
    "conf"                          = "60a06a1c02e42b36c3b4919f4d6de6bf"
    "whatcanidofor"                 = "d9e45851002a623e10f6954ff9a85d21"
    "openpgpkey"                    = "d20c137368e26dcc3db56d45a368e729"
    "openpgpkey.master-key"         = "3eea8f39a9b473a5dc7c188366f84072"
    "bugs"                          = "e41ef82b1a2d063ae958a4d5a3b2f870"
    "package-maintainer-bylaws.aur" = "680c89d189c8f342cc00bcb624d813a3"
    "terms"                         = "0b62a71af2aa85fb491295b543b4c3d2"
    "patchwork"                     = "37eeadf24d5cd6614e8edb1f12868a5e"
    "panic"                         = "5112598cea498d8df7fcdfbcb2e33fe6"
  }

  archlinux_page_gitlab_pages = {
    "repod"           = "f2d1ad84f7e9f22cd881d3bef58263e0"
    "rfc"             = "b457db2ce4ac4e162d2f4435f1fe1f39"
    "monthly-reports" = "a2d60657e960b480cdb229df7cc7edf3"
    "pacman"          = "3c5fb9413c1d66dac516a08277575662"
    "alpm"            = "363d06e0957fbfd22403e4dd992afc48"
    "signstar"        = "5c348888c16d81166379017879a29fe3"
    "devblog"         = "b4af31061ba3a13d82a1ce69897acf9b"
    "voa"             = "9c326f517d3d4248b7223fd220287d89"
    "manual"          = "df7e144644be537891582e89c9942957"
    "ports"           = "a110b58a4a74de2f8ff0e02bb731ab0f"
  }

  # This creates archlinux.org TXT DNS entries
  # Valid parameters are:
  #   - ttl (optional)
  #   - value, automatically wrapped in hcloud::txt_record (mandatory)
  #
  # Example:
  # "_github-challenge-archlinux" = { ttl = 3600, value = "824af4446e" }
  archlinux_org_txt = {
    "dkim-ed25519._domainkey.lists" = { value = "v=DKIM1; k=ed25519;p=ongbdFgt5Vimg/VRRbbSVRU4lBCkcYNaPA4K3JS/DnY=" }
    "dkim-rsa._domainkey.lists"     = { value = "v=DKIM1; k=rsa; p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA4M+y3ZeB9eI3GVgcrvMcI1SYOveH7P5TTRstaCHTlE/aRTiCzu5h6zKwwxEiK6NR5ugbHpBtfFnfnsl1eoaXVFBQfNdDNglHllJOZGVxTnyrFjRJUk9zN+PV/Haz73nAe1hOAENgV8NKnTok1ntaOYSH1AEj4yTswfQkuN23NPrQc1eyy3+hGC+lYpud3xAAl+oT4QE76PaLgk6HzHOvZmAPGD3azJZRbobninZZXTAEvZFuPkfpWeUreDU9Hk9VX3zOmnqTN+YjIS5CdV6+Ghem3dCkmR9j3gOZBeBUYD7b+cinTYe/PZO2OG/LWCwN11EYyf1LSBGhBJCF9HPGiGIdhy5T62nKvwDQS0bj1HL+y6pXZdv2C7KgH+lAZ0idpOQ2TtV5e0tlVdryY4QXY9m7mSQ84WsoEdGDsetOhiTEKuqyGnDoYa0wYbM5477LL6EOzS0x3ZC/mbOgB+FSdzmLWCH/WjuzMNpw9WU+u4BucwVbYcnZ1vAxQQOEnA/Ku9drRHMFixBwodQuMA78j8ICCMJKlUiXmbbL7OFoXBArYJ7lgVs7mlaoEaqzDPCyqs1lJ9kOxdNoZj5zdxERcQhLm+Yo/948i6Js/nkWT0eAjNlHxZuCg3B4z7L4lRZpaGt+vHdcGUIeDKW34O0dWxPwIUmQA4CwmhUB0HWL9UcCAwEAAQ==" }
    "dkim-ed25519._domainkey"       = { value = "v=DKIM1; k=ed25519; p=XOHB7b7V1puX+FryNIhsjXHYIFqk+q6JRu4XQ7Jc8MQ=" }
    "dkim-rsa._domainkey"           = { value = "v=DKIM1; k=rsa; p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1GjGrEczq7iHZbvT7wa4ltJz2jwSndUGdRHgfEPnGBeevOXEAlEFr4zsdkfZEaNaQLIhZNpvKAt/A+kkyalkj4u9AnxqeNsNmZflFl6TKgvh0tWNEP3+XNxfdQ7zfml4WggL/YdAjXngg42oZEUsnS/6iozOFn7bNvzqBx5PFJ21pgyuR8DWyLaeOt+p55dVed7DCKnKi11Xjiu7kH68W8rose7g8Fv9fecBatEE4jwloOXsjh+tH0iab1NSSSpIq6EdgcPrpmrllN3/n2J/kCGK6ztISB6vR7xWgvgHSMjmEL0GPWzohGPrw2UQhZhrNV8dJpiLRYmfK+rXaKF0Kqag/F0e4C4jCKFX7NYFcYXYRlN5QlDFjZvUmOILlgnZ8w/SdZUKzpLObGuwnANLG+WSOjw42p9mXVGN6AfOQPu8OjRjS1MyhcdDIbUvZiQjbmiVJ5frpYZ39BTgCIzYLJJ5932+3gnwROu1OeljWkpBkfHZXPzADus80l3Vxsk91XZVB36rN8tyuMownR/M4HNC7ZE/EBwOnn1mGH7bLd6pva8u5Qy8Y6LrDdYea5Kk7aZ2WJSSRTV+nkPvOEIx+DfsIWNfmkVWzmuVky96fRvwOCuh38w8zpmlqzhDuGSQrBaLFXwAC7LYQ6kPDHzrjQhs99ScR0ix6YclrmpimMcCAwEAAQ==" }

    "_dmarc"                          = { value = "v=DMARC1; p=none; rua=mailto:dmarc-reports@archlinux.org; ruf=mailto:dmarc-reports@archlinux.org;" }
    "_github-challenge-archlinux"     = { value = "824af4446e" }
    "_github-challenge-archlinux.www" = { value = "b53f311f86" }

    # TLS-RPT + MTA-STS + SPF
    "_smtp._tls"            = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    "_smtp._tls.aur"        = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    "_smtp._tls.master-key" = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    "_smtp._tls.gitlab"     = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    "_smtp._tls.lists"      = { value = "v=TLSRPTv1;rua=mailto:postmaster@archlinux.org" }
    # Generated with: date +%Y%m%d01
    "_mta-sts"   = { value = "v=STSv1; id=2022051602" }
    "@"          = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all" }
    "mail"       = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all" }
    "aur"        = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all" }
    "master-key" = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all" }
    gitlab       = { value = "v=spf1 ip4:${hcloud_server.machine["mail.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["mail.archlinux.org"].ipv6_address} ~all" }
    lists        = { value = "v=spf1 ip4:${hcloud_server.machine["lists.archlinux.org"].ipv4_address} ip6:${hcloud_server.machine["lists.archlinux.org"].ipv6_address} ~all" }
  }

  # This creates archlinux.org MX DNS entries
  # Valid parameters are:
  #   - mx (mandatory)
  #   - ttl (optional)
  #
  # Example:
  # "lists" = { mx = "lists.archlinux.org.", ttl = 3600 }
  archlinux_org_mx = {
    "@"        = { mx = "mail.archlinux.org." }
    aur        = { mx = "mail.archlinux.org." }
    master-key = { mx = "mail.archlinux.org." }
    gitlab     = { mx = "mail.archlinux.org." }
    lists      = { mx = "lists.archlinux.org." }
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
  # archive = {
  #   ipv4_address = "49.12.124.107"
  #   ipv6_address = "2a01:4f8:242:5614::2"
  #   ttl          = 3600
  # }
  archlinux_org_a_aaaa = {
    "@" = {
      ipv4_address = "209.126.35.79"
      ipv6_address = "2604:cac0:a104:d::3"
      ttl          = 60
    }
    archive = {
      ipv4_address = "49.12.124.107"
      ipv6_address = "2a01:4f8:242:5614::2"
    }
    aur = {
      ipv4_address = "209.126.35.78"
      ipv6_address = "2604:cac0:a104:d::2"
      ttl          = 60
    }
    build = {
      ipv4_address = "162.55.28.166"
      ipv6_address = "2a01:4f8:2190:20e0::2"
    }
    gitlab = {
      ipv4_address = "213.133.111.15"
      ipv6_address = "2a01:4f8:222:174c::1"
    }
    man = {
      # From HAProxy
      ipv4_address = "209.126.35.76"
      ipv6_address = "2604:cac0:a104:d::0"
      ttl          = 60
    }
    master-key = {
      ipv4_address = "209.126.35.79"
      ipv6_address = "2604:cac0:a104:d::3"
      ttl          = 60
    }
    pages = {
      ipv4_address = "213.133.111.6"
      ipv6_address = "2a01:4f8:222:174c::2"
    }
    repos = {
      ipv4_address = "168.119.141.106"
      ipv6_address = "2a01:4f8:251:598::"
      http3        = true
    }
    secure-runner1 = {
      ipv4_address = "116.202.134.150"
      ipv6_address = "2a01:4f8:231:4e1e::2"
    }
    runner2 = {
      ipv4_address = "157.180.104.115"
      ipv6_address = "2a01:4f9:3090:11cb::2"
    }
    wiki = {
      ipv4_address = "209.126.35.81"
      ipv6_address = "2604:cac0:a104:d::4"
      ttl          = 60
    }
    www = {
      ipv4_address = "209.126.35.79"
      ipv6_address = "2604:cac0:a104:d::3"
      ttl          = 60
    }
  }

  # This creates archlinux.org CNAME DNS entries.
  # Valid parameters are:
  #   - value (mandatory, the target for the CNAME "redirect")
  #   - ttl (optional)
  #
  # Example:
  # dev                      = { value = "www.archlinux.org.", ttl = 3600 }
  archlinux_org_cname = {
    ipxe             = { value = "www.archlinux.org." }
    mailman          = { value = "redirect.archlinux.org." }
    packages         = { value = "www.archlinux.org." }
    ping             = { value = "redirect.archlinux.org." }
    planet           = { value = "www.archlinux.org." }
    registry         = { value = "gitlab.archlinux.org." }
    "*.buildbtw.dev" = { value = "buildbtw.dev.archlinux.org." }
    rsync            = { value = "repos.archlinux.org." }
    sources          = { value = "repos.archlinux.org." }
    "static.conf"    = { value = "redirect.archlinux.org." }
    status           = { value = "stats.uptimerobot.com." }
    coc              = { value = "redirect.archlinux.org." }
    git              = { value = "redirect.archlinux.org." }
    "tu-bylaws.aur"  = { value = "redirect.archlinux.org." }

    # MTA-STS
    mta-sts               = { value = "mail.archlinux.org." }
    "mta-sts.aur"         = { value = "mail.archlinux.org." }
    "_mta-sts.aur"        = { value = "_mta-sts.archlinux.org." }
    "mta-sts.master-key"  = { value = "mail.archlinux.org." }
    "_mta-sts.master-key" = { value = "_mta-sts.archlinux.org." }
    "mta-sts.gitlab"      = { value = "mail.archlinux.org." }
    "_mta-sts.gitlab"     = { value = "_mta-sts.archlinux.org." }
    "mta-sts.lists"       = { value = "mail.archlinux.org." }
    "_mta-sts.lists"      = { value = "_mta-sts.archlinux.org." }
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
    "berlin.mirror" = {
      ipv4_address = "45.142.247.77"
      ipv6_address = "2a12:8d02:2100:10d:26a3:f0ff:fe47:bfaf"
      http3        = true
    }
    "frankfurt.mirror" = {
      ipv4_address = "138.199.19.15"
      ipv6_address = "2a02:6ea0:c72e::2"
      http3        = true
    }
    "johannesburg.mirror" = {
      ipv4_address = "102.130.49.241"
      ipv6_address = "2a0b:4342:1a91:3b5:26a3:f0ff:fe49:9bf9"
      http3        = true
    }
    "london.mirror" = {
      ipv4_address = "185.73.44.89"
      ipv6_address = "2001:ba8:0:4030::2"
      http3        = true
    }
    "losangeles.mirror" = {
      ipv4_address = "209.209.59.11"
      ipv6_address = "2a0e:6901:110:95:26a3:f0ff:fe48:999e"
      http3        = true
    }
    "singapore.mirror" = {
      ipv4_address = "194.156.163.63"
      ipv6_address = "2407:b9c0:e002:166:26a3:f0ff:fe46:6e9c"
      http3        = true
    }
    "taipei.mirror" = {
      ipv4_address = "45.150.242.222"
      ipv6_address = "2407:b9c0:b001:c4:26a3:f0ff:fe46:b1dc"
      http3        = true
    }
    repro4 = {
      ipv6_address = "2001:1470:fffd:3050::189:1"
    }
    test = {
      # From HAProxy
      ipv4_address = "209.126.35.77"
      ipv6_address = "2604:cac0:a104:d::1"
    }
    "umea.mirror" = {
      ipv4_address = "194.71.11.121"
      ipv6_address = "2001:6b0:19:2::121"
      http3        = true
    }
    "umea.archive" = {
      ipv4_address = "194.71.11.121"
      ipv6_address = "2001:6b0:19:2::121"
      http3        = true
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
      ipv4_address = "213.133.111.6"
      ipv6_address = "2a01:4f8:222:174c::2"
    }
  }

  # Domains served by machines in the geo_mirrors group
  # Valid parameters are:
  #   - name (mandatory, specifies the subdomain to create in the above zone)
  #   - zone (optional, defaults to hcloud_zone.archlinux_org.id)
  #   - ttl (optional, the TTL of the NS records, defaults to 86400 if unset)
  #
  # Note: If you use a custom TTL, also add it to geo_options[domain]['ns_ttl']
  #       in Ansible (see the 'geo_options' variable in group_vars/all/geo.yml)
  #
  geo_domains = {
    "geo.mirror.pkgbuild.com" = {
      name = "geo.mirror"
      zone = hcloud_zone.pkgbuild_com.name
    }
    "riscv.mirror.pkgbuild.com" = {
      name = "riscv.mirror"
      zone = hcloud_zone.pkgbuild_com.name
    }
  }
}

resource "hcloud_zone" "archlinux_org" {
  name              = "archlinux.org"
  mode              = "primary"
  ttl               = 3600
  delete_protection = true
}

resource "hcloud_zone" "archlinux_page" {
  name              = "archlinux.page"
  mode              = "primary"
  ttl               = 3600
  delete_protection = true
}

resource "hcloud_zone" "pkgbuild_com" {
  name              = "pkgbuild.com"
  mode              = "primary"
  ttl               = 3600
  delete_protection = true
}

resource "hcloud_zone_rrset" "archlinux_page_origin_caa" {
  zone = hcloud_zone.archlinux_page.name
  name = "@"
  type = "CAA"
  records = [
    { value = "0 issue \"letsencrypt.org\"" },
  ]
}

resource "hcloud_zone_rrset" "archlinux_page_origin_mx" {
  zone = hcloud_zone.archlinux_page.name
  name = "@"
  type = "MX"
  records = [
    { value = "0 ." },
  ]
}

resource "hcloud_zone_rrset" "archlinux_page_archinstall_cname" {
  zone = hcloud_zone.archlinux_page.name
  name = "archinstall"
  type = "CNAME"
  records = [
    { value = "archlinux.github.io." },
  ]
}

resource "hcloud_zone_rrset" "pkgbuild_com_teapot_mirror_cname" {
  zone = hcloud_zone.pkgbuild_com.name
  name = "teapot.mirror"
  type = "CNAME"
  records = [
    { value = "t.sni.global.fastly.net." },
  ]
}

resource "hcloud_zone_rrset" "pkgbuild_com_fastly_mirror_cname" {
  zone = hcloud_zone.pkgbuild_com.name
  name = "fastly.mirror"
  type = "CNAME"
  records = [
    { value = "dualstack.t.sni.global.fastly.net." },
  ]
}

resource "hcloud_zone_rrset" "archlinux_page_origin_ns" {
  zone = hcloud_zone.archlinux_page.name
  name = "@"
  type = "NS"
  ttl  = 86400
  records = [
    { value = "hydrogen.ns.hetzner.com." },
    { value = "oxygen.ns.hetzner.com." },
    { value = "helium.ns.hetzner.de." },
  ]
}

resource "hcloud_zone_rrset" "archlinux_page_sandbox_ns" {
  zone = hcloud_zone.archlinux_page.name
  name = "sandbox"
  type = "NS"
  ttl  = 86400
  records = [
    { value = "redirect.archlinux.org." },
  ]
}

resource "hcloud_zone_rrset" "archlinux_page_origin_soa" {
  zone = hcloud_zone.archlinux_page.name
  name = "@"
  type = "SOA"
  records = [
    { value = "hydrogen.ns.hetzner.com. dns.hetzner.com. 0 86400 10800 3600000 3600" },
  ]
}

resource "hcloud_zone_rrset" "archlinux_page_origin_txt" {
  zone = hcloud_zone.archlinux_page.name
  name = "@"
  type = "TXT"
  records = [
    { value = provider::hcloud::txt_record("v=spf1 -all") },
  ]
}

resource "hcloud_zone_rrset" "pages_verification_code_archlinux_page_origin_txt" {
  zone = hcloud_zone.archlinux_page.name
  name = "_gitlab-pages-verification-code"
  type = "TXT"
  records = [
    { value = provider::hcloud::txt_record("gitlab-pages-verification-code=0b9e3fc74735f5d83c7cfc86883b40cb") },
  ]
}

resource "hcloud_zone_rrset" "pkgbuild_com_origin_caa" {
  zone = hcloud_zone.pkgbuild_com.name
  name = "@"
  type = "CAA"
  records = [
    { value = "0 issue \"letsencrypt.org\"" },
  ]
}

resource "hcloud_zone_rrset" "pkgbuild_com_origin_mx" {
  zone = hcloud_zone.pkgbuild_com.name
  name = "@"
  type = "MX"
  records = [
    { value = "0 ." },
  ]
}

resource "hcloud_zone_rrset" "pkgbuild_com_origin_ns" {
  zone = hcloud_zone.pkgbuild_com.name
  name = "@"
  type = "NS"
  ttl  = 86400
  records = [
    { value = "hydrogen.ns.hetzner.com." },
    { value = "oxygen.ns.hetzner.com." },
    { value = "helium.ns.hetzner.de." },
  ]
}

resource "hcloud_zone_rrset" "pkgbuild_com_origin_soa" {
  zone = hcloud_zone.pkgbuild_com.name
  name = "@"
  type = "SOA"
  records = [
    { value = "hydrogen.ns.hetzner.com. dns.hetzner.com. 0 86400 10800 3600000 3600" },
  ]
}

resource "hcloud_zone_rrset" "pkgbuild_com_origin_txt" {
  zone = hcloud_zone.pkgbuild_com.name
  name = "@"
  type = "TXT"
  records = [
    { value = provider::hcloud::txt_record("v=spf1 -all") },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_origin_caa" {
  zone = hcloud_zone.archlinux_org.name
  name = "@"
  type = "CAA"
  records = [
    { value = "0 issue \"letsencrypt.org\"" },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_origin_ns" {
  zone = hcloud_zone.archlinux_org.name
  name = "@"
  type = "NS"
  ttl  = 86400
  records = [
    { value = "hydrogen.ns.hetzner.com." },
    { value = "oxygen.ns.hetzner.com." },
    { value = "helium.ns.hetzner.de." },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_acme_challenge_buildbtw_dev_ns" {
  zone = hcloud_zone.archlinux_org.name
  name = "_acme-challenge.buildbtw.dev"
  type = "NS"
  ttl  = 86400
  records = [
    { value = "redirect.archlinux.org." },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_acme_challenge_mumble_ns" {
  zone = hcloud_zone.archlinux_org.name
  name = "_acme-challenge.mumble"
  type = "NS"
  ttl  = 86400
  records = [
    { value = "redirect.archlinux.org." },
  ]
}

resource "hcloud_zone_rrset" "archlinux_org_origin_soa" {
  zone = hcloud_zone.archlinux_org.name
  name = "@"
  type = "SOA"
  records = [
    { value = "hydrogen.ns.hetzner.com. dns.hetzner.com. 0 86400 10800 3600000 3600" },
  ]
}

resource "hcloud_volume" "mirror" {
  name              = "mirror"
  size              = 150
  server_id         = hcloud_server.machine["mirror.pkgbuild.com"].id
  delete_protection = true
}

resource "hcloud_volume" "homedir" {
  name              = "homedir"
  size              = 150
  server_id         = hcloud_server.machine["homedir.archlinux.org"].id
  delete_protection = true
}

resource "hcloud_volume" "monitoring" {
  name              = "monitoring"
  size              = 215
  server_id         = hcloud_server.machine["monitoring.archlinux.org"].id
  delete_protection = true
}

resource "hcloud_volume" "debuginfod" {
  name              = "debuginfod"
  size              = 125
  server_id         = hcloud_server.machine["debuginfod.archlinux.org"].id
  delete_protection = true
}

resource "hcloud_floating_ip" "whitelist_ip_bastion_archlinux_org" {
  name              = "bastion-host-IP-DO-NO-DELETE"
  type              = "ipv4"
  server_id         = hcloud_server.machine["bastion.archlinux.org"].id
  delete_protection = true
}
