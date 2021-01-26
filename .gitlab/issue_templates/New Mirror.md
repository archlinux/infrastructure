<!--
This template should be used for adding a new Arch Linux Mirror on our own infrastructure.
-->

## Details

- **Server name**: <!-- Put server hostname here -->

## Steps

1. [ ] Verify if the new mirror has enough diskspace for hosting a mirror.
1. [ ] Add the new mirror in [archweb](https://archlinux.org/admin/mirrors/mirror/add) with these values:
   - `Name`: <domain-name>
   - `Tier`: `Tier 1`
   - `Upstream`: `rsync.archlinux.org`
   - `Public`: `checked`
   - `Active`: `checked`
   - `ISOs`: `checked`
   - `Mirrors URLs`:
      * `URL`: `https://<domain-name>/`
      * `Country`: `Mirror country`
      * `Bandwidth`: `Mirror bandwidth`
   - `Mirrors Rsync IPs`: `Add the IPv4 and IPv6 address`
1. [ ] Add a new domain in terraform
1. [ ] Add the new server to `mirrors` in `hosts`
1. [ ] Add a new `mirror_domain` key with <domain-name> as value
1. [ ] Run the `gen_rsyncd` service on `rsync.archlinux.org` or wait till the systemd timer is triggered.
1. [ ] Run the `mirrors.yml` playbook
1. [ ] Run `certbot certonly --email webmaster@archlinux.org --agree-tos --rsa-key-size 4096 --renew-by-default --webroot -w /var/lib/letsencrypt/ -d <domain-name>`
