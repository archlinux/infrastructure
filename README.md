# Arch Infrastructure

This repository contains the complete collection of ansible playbooks and roles for the Arch Linux infrastructure.

#### Instructions
All systems are set up the same way. For the first time setup in the Hetzner rescue system,
run the provisioning script: `ansible-playbook playbooks/$hostname-provision.yml`.
The provisioning script configures a sane basic systemd with sshd. By design, it is NOT idempotent.
After the provisioning script has run, it is safe to reboot.

Once in the new system, run the regular playbook: `ansible-playbook playbooks/$hostname.yml`. This
playbook is the one regularily used for adminstrating the server and is entirely idempotent.

## Servers

### vostok

#### Services
- backups

### orion

#### Services
- repos/sync (repos.archlinux.org)
- sources
- archive (archive.archlinux.org)

### apollo

#### Services
- bbs (bbs.archlinux.org)
- wiki (wiki.archlinux.org)
- aur (aur.archlinux.org)
- mailman
- planet
- bugs (bugs.archlinux.org)
- archweb
- patchwork
- projects

### soyuz

#### Services
- build server (pkgbuild.com)
- releng
- torrent tracker
