# Arch Infrastructure

This repository contains the complete collection of ansible playbooks and roles for the Arch Linux infrastructure.

It also contains git submodules so you have to run `git submodule update --init
--recursive` after cloning or some tasks will fail to run.

## Requirements

Install these packages:
- terraform

### Instructions

All systems are set up the same way. For the first time setup in the Hetzner rescue system,
run the provisioning script: `ansible-playbook playbooks/tasks/install-arch.yml -l $host`.
The provisioning script configures a sane basic systemd with sshd. By design, it is NOT idempotent.
After the provisioning script has run, it is safe to reboot.

Once in the new system, run the regular playbook: `HCLOUD_TOKEN=$(misc/get_key.py misc/vault_hetzner.yml hetzner_cloud_api_key) ansible-playbook playbooks/$hostname.yml`.
This playbook is the one regularity used for administrating the server and is entirely idempotent.

#### Note about Ansible dynamic inventories

We use a dynamic inventory script in order to automatically get information for
all servers directly from hcloud. You don't really have to do anything to make
this work but you should keep in mind to NOT add hcloud servers to `hosts`!
They'll be available automatically.

#### Note about first time certificates

The first time a certificate is issued, you'll have to do this manually by yourself. First, configure the DNS to
point to the new server and then run a playbook onto the server which includes the nginx role. Then on the server,
it is necessary to run the following once:

    certbot certonly --email webmaster@archlinux.org --agree-tos --rsa-key-size 4096 --renew-by-default --webroot -w /var/lib/letsencrypt/ -d <domain-name>

Note that some roles already run this automatically.

#### Note about packer

We use packer to build snapshots on hcloud to use as server base images.
In order to use this, you need to install packer and then run

	packer build -var $(misc/get_key.py misc/vault_hetzner.yml hetzner_cloud_api_key env) packer/archlinux.json

This will take some time after which a new snapshot will have been created on the primary hcloud archlinux project.

#### Note about terraform

We use terraform to provision a part of the infrastructure on hcloud.
The very first time you run terraform on your system, you'll have to init it:

    terraform init -backend-config="conn_str=postgres://terraform:$(misc/get_key.py group_vars/all/vault_terraform.yml vault_terraform_db_password)@state.cloud.archlinux.org"

After making changes to the infrastructure in `archlinux.fg`, run

    terraform plan

This will show you planned changes between the current infrastructure and the desired infrastructure.
You can then run

    terraform apply

to actually apply your changes.

We store terraform state on a special server that is the only hcloud server NOT
managed by terraform so that we do not run into a chicken-egg problem. The
state server is assumed to just exist so in an unlikely case where we have to
entirely redo this infrastructure, the state server would have to be manually
set up.

#### Note about opendkim

The opendkim DNS data has to be added to DNS manually. The roles verifies that the DNS is correct before starting opendkim.

The file that has to be added to the zone is `/etc/opendkim/private/$selector.txt`.


### Finding servers requiring security updates

Arch-audit can be used to find servers in need of updates for security issues.

    ansible all -a "arch-audit -u"

#### Updating servers

The following steps should be used to update our managed servers:

* pacman -Syu
* manually update the kernel, since it is in IgnorePkg by default
* sync
* checkservices
* reboot

## Servers

### vostok

#### Services
- backups

### orion

#### Services
- repos/sync (repos.archlinux.org)
- sources (sources.archlinux.org)
- archive (archive.archlinux.org)
- torrent tracker hefurd (tracker.archlinux.org)

### apollo

#### Services
- bbs (bbs.archlinux.org)
- wiki (wiki.archlinux.org)
- aur (aur.archlinux.org)
- flyspray (bugs.archlinux.org)
- mailman
- planet (planet.archlinux.org)
- bugs (bugs.archlinux.org)
- archweb
- patchwork
- projects (projects.archlinux.org)

### soyuz

#### Services
- build server (pkgbuild.com)
- releng
- sogrep
- /~user/ webhost
- irc bot (phrik)
- matrix
- docker images
- arch boxes (packer)

### dragon

#### Services
- build server (pkgbuild.com)
- sogrep

### state.cloud.archlinux.org

#### Services:
- postgres server for terraform state

### quassel.archlinux.org

#### Services:
- quassel core

## Ansible repo workflows

### Replace vault password and change vaulted passwords

 - Generate a new key and save it as ./new-vault-pw: `pwgen -s 64 1 > new-vault-pw`
 - `for i in $(ag ANSIBLE_VAULT -l); do ansible-vault rekey --new-vault-password-file new-vault-pw $i; done`
 - Change the key in misc/vault-password.gpg
 - `rm new-vault-pw`

