# Arch Infrastructure

This repository contains the complete collection of ansible playbooks and roles for the Arch Linux infrastructure.

#### Instructions
All systems are set up the same way. For the first time setup in the Hetzner rescue system,
run the provisioning script: `ansible-playbook playbooks/$hostname-provision.yml`.
The provisioning script configures a sane basic systemd with sshd. By design, it is NOT idempotent.
After the provisioning script has run, it is safe to reboot.

Once in the new system, run the regular playbook: `ansible-playbook playbooks/$hostname.yml`. This
playbook is the one regularily used for adminstrating the server and is entirely idempotent.

##### Note about first time certificates

The first time a certificate is issued, you'll have to do this manually by yourself. First, configure the DNS to
point to the new server and then run a playbook onto the server which includes the nginx role. Then on the server,
it is necessary to run the following once:

certbot certonly --email webmaster@archlinux.org --agree-tos --rsa-key-size 4096 --renew-by-default --webroot -w /var/lib/letsencrypt/ -d <domain-name>

## Servers

### vostok

#### Services
- backups

### orion

#### Services
- repos/sync (repos.archlinux.org)
- sources (sources.archlinux.org)
- archive (archive.archlinux.org)

### apollo

#### Services
- bbs (bbs.archlinux.org)
- wiki (wiki.archlinux.org)
- aur (aur.archlinux.org)
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
- torrent tracker
