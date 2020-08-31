terraform {
  backend "pg" {
    schema_name = "terraform_remote_state_stage1"
  }
}

data "external" "hetzner_cloud_api_key" {
  program = ["${path.module}/../misc/get_key.py", "misc/vault_hetzner.yml", "hetzner_cloud_api_key", "--format", "json"]
}

data "hcloud_image" "archlinux" {
  with_selector = "custom_image=archlinux"
  most_recent   = true
  with_status   = ["available"]
}

provider "hcloud" {
  token = data.external.hetzner_cloud_api_key.result.hetzner_cloud_api_key
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
    command = "ansible-playbook --ssh-extra-args '-o StrictHostKeyChecking=no' playbooks/accounts.archlinux.org.yml"
  }
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_volume" "mirror" {
  name = "mirror"
  size = 100
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
  name = "homedir"
  size = 100
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
  server_type = "cpx31"
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

resource "hcloud_rdns" "secure-runner2_ipv4" {
  server_id  = hcloud_server.secure-runner2.id
  ip_address = hcloud_server.secure-runner2.ipv4_address
  dns_ptr    = "secure-runner2.archlinux.org"
}

resource "hcloud_rdns" "secure-runner2_ipv6" {
  server_id  = hcloud_server.secure-runner2.id
  ip_address = hcloud_server.secure-runner2.ipv6_address
  dns_ptr    = "secure-runner2.archlinux.org"
}

resource "hcloud_server" "secure-runner2" {
  name        = "secure-runner2.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
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
