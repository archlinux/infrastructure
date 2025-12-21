# Arch Infrastructure

This repository contains the complete collection of ansible playbooks and
terraform configuration for the Arch Linux infrastructure.

## Table of contents

[[_TOC_]]

## Requirements

Install these packages:

- `terraform`
- `python-click`
- `python-jmespath`
- `moreutils` (for `playbooks/tasks/reencrypt-vault-key.yml`)

### Instructions

All systems are set up the same way. For the first time setup in the Hetzner
rescue system, run the provisioning script:

```
ansible-playbook playbooks/tasks/install_arch.yml -l $host
```

The provisioning script configures a sane basic systemd with sshd. By design,
it is NOT idempotent. After the provisioning script has run, it is safe to
reboot.

Once in the new system, run the regular playbook:

```
HCLOUD_TOKEN=$(misc/get_key.py misc/vaults/vault_hetzner.yml hetzner_cloud_api_key) ansible-playbook playbooks/$hostname.yml`
```

This playbook is the one regularity used for administrating the server and is
entirely idempotent.

When adding a new machine you should also deploy our SSH known_hosts file and
update the SSH hostkeys file in this git repo. For this you can simply run the
`playbooks/tasks/sync-ssh-hostkeys.yml` playbook and commit the changes it
makes to this git repository.
It will also deploy any new SSH host keys to all our machines.

#### Note about GPG keys

The `root_access.yml` file contains the `vault_default_pgpkeys` variable which
determines the users that have access to the `default` vault, as well as the
borg backup keys. A separate `super` vault exists for storing highly sensitive
secrets like Hetzner credentials; access to the `super` vault is controlled by
the `vault_super_pgpkeys` variable.

All the keys should be on the local user gpg keyring and at **minimum** be
locally signed with `--lsign-key` (or if you use TOFU, have `--tofu-policy
good`). This is necessary for running any of the `reencrypt-vault-default-key`,
`reencrypt-vault-super-key` or `fetch-borg-keys` tasks.

#### Note about packer

We use packer to build snapshots on hcloud to use as server base images.
In order to use this, you need to install packer and then run

```
packer build -var $(misc/get_key.py misc/vaults/vault_hetzner.yml hetzner_cloud_api_key --format env) packer/archlinux.pkr.hcl
```

This will take some time after which a new snapshot will have been created on
the primary hcloud archlinux project.

For the sandbox project please run

```
packer build -var $(misc/get_key.py misc/vaults/vault_hetzner.yml hetzner_cloud_sandbox_infrastructure_api_key --format env | sed 's/_sandbox_infrastructure//') -var install_ec2_public_keys_service=true packer/archlinux.pkr.hcl
```

#### Note about terraform

See [docs/terraform.md](./docs/terraform.md) for details about terraform.

#### SMTP Configuration

All hosts should be relaying email through our primary mx host (currently
'mail.archlinux.org'). See [docs/email.md](./docs/email.md) for full details.

### Putting a service in maintenance mode

Most web services with a nginx configuration, can be put into a maintenance
mode, by running the playbook with a maintenance variable:

```
ansible-playbook -e maintenance=true playbooks/<playbook.yml>
```

This also works with a tag:

```
ansible-playbook -t <tag> -e maintenance=true playbooks/<playbook.yml>
```

As long as you pass the maintenance variable to the playbook run, the web
service will stay in maintenance mode. As soon as you stop passing it on the
command line and run the playbook again, the regular nginx configuration should
resume and the service should accept requests by the end of the run.

Passing `maintenance=false`, will also prevent the regular nginx configuration
from resuming, but will not put the service into maintenance mode.

Keep in mind that passing the maintenance variable to the whole playbook,
without any tag, will make all the web services that have the
maintenance mode in them, to be put in maintenance mode. Use tags to affect
only the services you want.

Documentation on how to add the maintenance mode to a web service is inside
[docs/maintenance.md](./docs/maintenance.md).

### Finding servers requiring security updates

Arch-audit can be used to find servers in need of updates for security issues.

```
ansible all -a "arch-audit -u"
```

### Semi-automated server upgrades

For updating all servers in a mostly unattented manner, the following playbook
can be used:

```
ansible-playbook playbooks/tasks/upgrade-servers.yml [-l SUBSET]
```

It runs `pacman -Syu` on the targeted hosts in batches and then reboots them.
If any server fails to reboot successfully, the rolling update stops and
further batches are cancelled. To display the packages updated on each host,
you can pass the `--diff` option to ansible-playbook.

Using this update method, `.pacnew` files are left unmerged which is OK for
most configuration files that are managed by Ansible. However, care must be
taken with updates that require manual intervention (e.g. major PostgreSQL
releases).

## Servers

This section has been moved to [docs/servers.md](docs/servers.md).

## Ansible repo workflows

### Fetching the borg keys for local storage

- Make sure you have all the GPG keys **at least** locally signed
- Run the `playbooks/tasks/fetch-borg-keys.yml` playbook
- Make sure the playbook runs successfully and check the keys under the
  borg-keys directory

### Re-encrypting the vaults after adding a new PGP key

Follow the instructions in [`group_vars/all/root_access.yml`](group_vars/all/root_access.yml).

### Changing the vault password on encrypted files

See [docs/vault-rekeying.md](docs/vault-rekeying.md).

## Backup documentation

We use BorgBackup for all of our backup needs. We have a primary backup storage
as well as an additional offsite backup.

See [docs/backups.md](./docs/backups.md) for detailed backup information.

## Updating Gitlab

Our Gitlab installation uses [Omnibus](https://docs.gitlab.com/omnibus/) to run
Gitlab on Docker. Updating Gitlab is as simple as running the ansible gitlab
playbook:

```
ansible-playbook playbooks/gitlab.archlinux.org.yml --diff -t gitlab
```

To view the current Gitlab version visit [this url](https://gitlab.archlinux.org/help/)

## One-shots

A bunch of once-only admin task scripts can be found in `one-shots/`.
We try to minimize the amount of manual one-shot admin work we have to do but
sometimes for some migrations it might be necessary to have such scripts.
