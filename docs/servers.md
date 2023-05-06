# Servers

## Table of contents
[[_TOC_]]

## gemini

### Services
  - repos/sync (repos.archlinux.org)
  - sources (sources.archlinux.org)
  - archive (archive.archlinux.org)

## lists.archlinux.org

### Services

  - mailman

## archlinux.org

### Services
  - archweb (Arch's site)

## aur.archlinux.org

### Services
  - aurweb

## bugs.archlinux.org

### Services
  - flyspray

## bbs.archlinux.org

### Services
  - bbs

## phrik.archlinux.org

### Services
   - phrik (irc bot) users in the phrik group defined in
     the hosts vars and re-used the archusers role. Users
     in the phrik group are allowed to restar the irc bot.

## state.archlinux.org

### Services
  - postgres server for terraform state

## quassel.archlinux.org

### Services
  - quassel core

## matrix.archlinux.org

### Services
  - Matrix homeserver (Synapse)
  - Matrix ↔ IRC bridge

## homedir.archlinux.org

### Services
  - ~/user/ webhost

## accounts.archlinux.org

This server is _special_. It runs keycloak and is central to our unified Arch Linux account management world.
It has an Ansible playbook for the keycloak service but that only installs the package and starts it but it's configured via a secondary Terraform file only for keycloak `keycloak.tf`.
The reason for doing it this way is that Terraform support for Keycloak is much superior and it's declarative too which is great for making sure that no old config remains in the case of config changes.

So to set up this server from scratch, run:

  - `cd tf-stage1`
  - `terraform apply`
  - `cd ../tf-stage2`
  - `terraform import keycloak_realm.master master`
  - `terraform apply`

### Services
  - keycloak

## mirror.pkgbuild.com

### Services
  - Regular mirror.

## reproducible.archlinux.org

[Rebuilderd docs](./docs/rebuilderd.md)

### Services
  - Runs a master [rebuilderd](https://reproducible.archlinux.org) instance
    with two workers:
    - repro2.pkgbuild.com (Kape server with an EPYC 7702P and 256G RAM)
    - repro3.pkgbuild.com (Equinix Metal box with a Xeon E-2278G and 64G RAM)

## runner1.archlinux.org

Medium-fast-ish Kape Arch Linux box.

## runner3.archlinux.org

Medium-fast-ish Equinix Metal Arch Linux box.

### Services
  - GitLab runner

## mail.archlinux.org

### Services
  - postfix (mail server)
  - rspamd
  - dovecot (imap)

## monitoring.archlinux.org

  Prometheus, Loki and Grafana server which collects performance/metrics and logs from our services and runs alertmanager.

### Services
  - Alertmanager
  - [Grafana](https://monitoring.archlinux.org) and [docs/grafana.md](./docs/grafana.md)
  - Prometheus

## dashboards.archlinux.org

Prometheus, and Grafana server which receives selected performance/metrics from monitoring.archlinux.org and make them public accessible.

### Services
  - [Grafana](https://dashboards.archlinux.org) and [docs/grafana.md](./docs/grafana.md)
  - Prometheus

## redirect.archlinux.org

### Services
  - Redirects (nginx redirects)
  - Authoritative DNS server (PowerDNS) for ACME DNS challenges
  - ping

## security.archlinux.org

### Services
  - security tracker

## wiki.archlinux.org

### Services
  - archwiki

## md.archlinux.org

  Online collborative markdwown editor for Arch Linux Staff.

### Services
  - [hedgedoc](https://hedgedoc.org/)

## Archive Mirrors

The [Arch Linux Archive](https://archive.archlinux.org) is mirrored to three dedicated servers to help aid global availability.

### Servers
  - https://america.archive.pkgbuild.com
  - https://asia.archive.pkgbuild.com
  - https://europe.archive.pkgbuild.com

## gitlab.archlinux.org

### Services
- Gitlab