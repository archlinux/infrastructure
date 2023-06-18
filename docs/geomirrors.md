# Geo mirrors

DevOps team maintain a geo mirror across the world. The Geo mirror is public facing on geo.mirror.pkgbuild.com domain and it will resolve the closest to the location of the requester mirror.

## Locations

| Mirror | Location |
| ----------- | ----------- |
| https://sydney.mirror.pkgbuild.com/ | Australia |
| https://europe.mirror.pkgbuild.com/ | Czechia |
| https://asia.mirror.pkgbuild.com/ | Hong Kong |
| https://seoul.mirror.pkgbuild.com/ | South Korea |
| https://london.mirror.pkgbuild.com/ | United Kingdom |
| https://america.mirror.pkgbuild.com/ | United States |

### Logical split
The continent mirrors america, asia and europe contain the archive mirrors as well as repository mirrors. The city mirrors have just the repositories hosted.

## Requirements
- Host with Arch Linux installed
- root access provided
- Enough storage to host repos / debugrepos (at least)
- Bandwidth (depends on location)   

## Adding a new mirror box
- Add new entries in `hosts` file under `mirrors` and `geo_mirrors` sections
- Adjust terraform `tf-stage1/archlinux.tf` to include the IPv4 and IPv6 entries of the new server
- Adjust terraform `tf-stage1/templates.tf` to include the IPv4 and IPv6 entries of the new server as a `NS` record for `geo.mirror.pkgbuild.com`
- Add a new files in `host_vars`
    - `host_vars/<fqdn>/misc`
        Containing all the information for the mirror itself
    - `host_vars/<fqdn>/vault_wireguard.yml`
        Containing the wireguard private key in encrypted vault

## Ansible Playbooks execution

| Playbook | Roles | Reason | Hosts (limits) |Comments |
| ----------- | ----------- | ----------- | ----------- |  ----------- |
| install_arch | All | Install Arch | | Optional if you can |
| mirrors.yml | All | Setup mirror | `<fqdn>` | |
| redirect.archlinux.org.yml | acme_dns_challenge | Make TXT records | | |
| gemini.archlinux.org.yml | dbscripts | Allow debug repo syncing | | |
| mirrors.yml | geo_dns | Add new domain to DNS | All other mirrors from geo.mirror | |
| monitoring.archlinux.org.yml | wireguard,prometheus | Allow loki and prometheus to fetch data | | |
| archlinux.org.yml | postgres,wireguard | Allow wireguard IP to connect for Mirror check | | Optional see Check Location below |

### Add mirror in geo.mirror.pkgbuild.com

Add mirror IP and FQDN in archweb admin https://archlinux.org/admin/mirrors/mirror/ under the `geo.mirror.pkgbuild.com` entry.

### Check Location (optional)

If you want the server to check for ping and stats create an entry in:
 https://archlinux.org/admin/mirrors/checklocation/
