# Arch Infrastructure

This repository contains the complete collection of ansible playbooks and roles for the Arch Linux infrastructure.

It also contains git submodules so you have to run `git submodule update --init
--recursive` after cloning or some tasks will fail to run.

## Requirements

Install these packages:
  - terraform
  - terraform-provider-keycloak

### Instructions

All systems are set up the same way. For the first time setup in the Hetzner rescue system,
run the provisioning script: `ansible-playbook playbooks/tasks/install-arch.yml -l $host`.
The provisioning script configures a sane basic systemd with sshd. By design, it is NOT idempotent.
After the provisioning script has run, it is safe to reboot.

Once in the new system, run the regular playbook: `HCLOUD_TOKEN=$(misc/get_key.py misc/vault_hetzner.yml hetzner_cloud_api_key) ansible-playbook playbooks/$hostname.yml`.
This playbook is the one regularity used for administrating the server and is entirely idempotent.

When adding a new machine you should also deploy our SSH known_hosts file and update the SSH hostkeys file in this git repo.
For this you can simply run the `playbooks/tasks/sync-ssh-hostkeys.yml` playbook and commit the changes it makes to this git repository.
It will also deploy any new SSH host keys to all our machines.

#### Note about GPG keys

The root_access.yml file contains the root_gpgkeys variable that determine the users that have access to the vault, as well as the borg backup keys.
All the keys should be on the local user gpg keyring and at **minimum** be locally signed with --lsign-key. This is necessary for running either the reencrypt-vault-key
or the fetch-borg-keys tasks.

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

We use terraform in two ways:

    1) To provision a part of the infrastructure on hcloud (and possibly other service providers in the future)
    2) To declaratively configure applications

For both of these, we have set up a separate terraform script. The reason for that is that sadly terraform can't have
providers depend on other providers so we can't declaratively state that we want to configure software on a server which
itself needs to be provisioned first. Therefore, we use a two-stage process. Generally speaking, scenario 1) is configured in
`tf-stage1` and 2) is in `tf-stage2`. Maybe in the future, we can just have a single terraform script for everything
but for the time being, this is what we're stuck with.

The very first time you run terraform on your system, you'll have to init it:

    cd tf-stage1  # and also tf-stage2
    terraform init -backend-config="conn_str=postgres://terraform:$(../misc/get_key.py group_vars/all/vault_terraform.yml vault_terraform_db_password)@state.archlinux.org"

After making changes to the infrastructure in `tf-stage1/archlinux.fg`, run

    terraform plan

This will show you planned changes between the current infrastructure and the desired infrastructure.
You can then run

    terraform apply

to actually apply your changes.

The same applies to changed application configuration in which case you'd run
it inside of `tf-stage2` instead of `tf-stage1`.

We store terraform state on a special server that is the only hcloud server NOT
managed by terraform so that we do not run into a chicken-egg problem. The
state server is assumed to just exist so in an unlikely case where we have to
entirely redo this infrastructure, the state server would have to be manually
set up.

#### SMTP Configuration

All hosts should be relaying email through our primary mx host (currently 'orion'). See docs/email.txt for full details.

#### Note about opendkim

The opendkim DNS data has to be added to DNS manually. The roles verifies that the DNS is correct before starting opendkim.

The file that has to be added to the zone is `/etc/opendkim/private/$selector.txt`.

### Putting a service in maintenance mode

Most web services with a nginx configuration, can be put into a maintenance mode, by running the playbook with a maintenance variable:

    ansible-playbook -e maintenance=true playbooks/<playbook.yml>

This also works with a tag:

    ansible-playbook -t <tag> -e maintenance=true playbooks/<playbook.yml>

As long as you pass the maintenance variable to the playbook run, the web service will stay in maintenance mode. As soon as you stop
passing it on the command line and run the playbook again, the regular nginx configuration should resume and the service should accept
requests by the end of the run.

Passing maintenance=false, will also prevent the regular nginx configuration from resuming, but will not put the service into maintence
mode.

Keep in mind that passing the maintenance variable to the whole playbook, without any tag, will make all the web services that have the
maintenance mode in them, to be put in maintenance mode. Use tags to affect only the services you want.

Documentation on how to add the maintenance mode to a web service is inside docs/maintenance.txt

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

### luna

#### Services

  - aur (aur.archlinux.org)
  - mailman
  - projects (projects.archlinux.org)

### apollo

#### Services
  - wiki (wiki.archlinux.org)
  - bugs (bugs.archlinux.org)
  - archweb
  - patchwork

## bugs.archlinux.org

#### Services
  - flyspray

## bbs.archlinux.org

#### Services
  - bbs

### phrik.archlinux.org

#### Services
   - phrik (irc bot) users in the phrik group defined in
     the hosts vars and re-used the archusers role. Users
     in the phrik group are allowed to restar the irc bot.

### dragon

#### Services
  - build server
  - sogrep
  - arch-boxes (packer)

### state.archlinux.org

#### Services:
  - postgres server for terraform state

### quassel.archlinux.org

#### Services:
  - quassel core

### homedir.archlinux.org

#### Services:
  - ~/user/ webhost

### accounts.archlinux.org

This server is /special/. It runs keycloak and is central to our unified Arch Linux account management world.
It has an Ansible playbook for the keycloak service but that only installs the package and starts it but it's configured via a secondary Terraform file only for keycloak `keycloak.tf`.
The reason for doing it this way is that Terraform support for Keycloak is much superior and it's declarative too which is great for making sure that no old config remains in the case of config changes.

So to set up this server from scratch, run:

  - `cd tf-stage1`
  - `terraform apply`
  - `cd ../tf-stage2`
  - `terraform import keycloak_realm.master master`
  - `terraform apply`

#### Services:
  - keycloak

## mirror.pkgbuild.com

### Services
  - Load balancer for PIA mirrors across the world. Uses Maxmind's GeoIP City
    database for routing users to their nearest mirror. Account information is
    stored in the ansible vault.

## reproducible.archlinux.org

### Services
  - Runs a master rebuilderd instance with two PIA workers (repro1.pkgbuild.com,
    repro2.pkgbuild.com and repro3.pkgbuild.com).
    repro3.pkgbuild.com is packet.net machine which runs Ubuntu.

## Ansible repo workflows

### Replace vault password and change vaulted passwords

  - Generate a new key and save it as ./new-vault-pw: `pwgen -s 64 1 > new-vault-pw`
  - `for i in $(ag ANSIBLE_VAULT -l); do ansible-vault rekey --new-vault-password-file new-vault-pw $i; done`
  - Change the key in misc/vault-password.gpg
  - `rm new-vault-pw`

### Re-encrypting the vault after adding or removing a new GPG key

  - Make sure you have all the GPG keys **at least** locally signed
  - Run the playbooks/tasks/reencrypt-vault-key.yml playbook and make sure it does not have **any** failed task
  - Test that the vault is working by running ansible-vault view on any encrypted vault file
  - Commit and push your changes

### Fetching the borg keys for local storage

  - Make sure you have all the GPG keys **at least** locally signed
  - Run the playbooks/tasks/fetch-borg-keys.yml playbook
  - Make sure the playbook runs successfully and check the keys under the borg-keys directory

## Backup documentation

Backups should be checked now and then. Some common tasks:

### Listing current backups per server

    borg list borg@vostok.archlinux.org:/backup/<hostname>

Example

    borg list borg@vostok.archlinux.org:/backup/homedir.archlinux.org

### Listing files in a backup

    borg list borg@vostok.archlinux.org:/backup/<hostname>::<archive name>

Example

    borg list borg@vostok.archlinux.org:/backup/homedir.archlinux.org::20191127-084357

## One-shots

A bunch of once-only admin task scripts can be found in `one-shots/`.
We try to minimize the amount of manual one-shot admin work we have to do but sometimes for some migrations it might be necessary to have such scripts.
