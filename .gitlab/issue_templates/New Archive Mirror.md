<!--
This template should be used for adding a new Arch Linux Archive Mirror.
-->

# Add a new Archive Mirror Server

## Details

- **Server name**: <!-- Put server hostname here -->

## Steps

- [ ] Verify if the new mirror has enough diskspace for hosting the archive
- [ ] Add a new domain in terraform
- [ ] Add the new server to `archive_mirrors` in `hosts`
- [ ] Run the dbscripts role to allow the new archive mirror to sync
- [ ] Run the `archive-mirrors.yml` playbook
- [ ] Run `certbot certonly --email webmaster@archlinux.org --agree-tos --rsa-key-size 4096 --renew-by-default --webroot -w /var/lib/letsencrypt/ -d <domain-name>`
