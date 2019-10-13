---
mirror_domain: mirror.pkgbuild.com
archweb_mirrorcheck_locations: [7]
arch32_mirror_domain: mirror.archlinux32.org
filesystem: btrfs
zabbix_agent_templates:
  - Template OS Linux
  - Template App Borg Backup
  - Template App PostgreSQL
