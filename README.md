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

## Servers

This section has been moved to [docs/servers.md](docs/servers.md).

Documentation on upgrades and the maintenance mode is now in
[docs/maintenance.md](./docs/maintenance.md).

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

To view the current Gitlab version visit [this url](https://gitlab.archlinux.org/help/)

## One-shots

A bunch of once-only admin task scripts can be found in `one-shots/`.
We try to minimize the amount of manual one-shot admin work we have to do but
sometimes for some migrations it might be necessary to have such scripts.
