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

### Note about terraform

See [docs/terraform.md](./docs/terraform.md) for details about terraform.

### SMTP Configuration

All hosts should be relaying email through our primary mx host (currently
'mail.archlinux.org'). See [docs/email.md](./docs/email.md) for full details.

## Servers

This section has been moved to [docs/servers.md](docs/servers.md).

Documentation on upgrades and the maintenance mode is now in
[docs/maintenance.md](./docs/maintenance.md).

## Backup documentation

We use BorgBackup for all of our backup needs. We have a primary backup storage
as well as an additional offsite backup.

See [docs/backups.md](./docs/backups.md) for detailed backup information.

To view the current Gitlab version visit [this url](https://gitlab.archlinux.org/help/)

## One-shots

A bunch of once-only admin task scripts can be found in `one-shots/`.
We try to minimize the amount of manual one-shot admin work we have to do but
sometimes for some migrations it might be necessary to have such scripts.
