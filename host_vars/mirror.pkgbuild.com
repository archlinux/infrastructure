---
mirror_domain: mirror.pkgbuild.com
archweb_mirrorcheck_locations: [12, 13]
filesystem: btrfs
zabbix_agent_templates:
  - Template OS Linux
