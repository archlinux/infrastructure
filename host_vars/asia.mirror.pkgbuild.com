hostname: "asia.mirror.pkgbuild.com"
archive_domain: "asia.archive.pkgbuild.com"
ipv4_address: "84.17.57.98"
ipv4_netmask: "/24"
ipv4_gateway: "84.17.57.110"
ipv6_address: "2a02:6ea0:d605::2"
ipv6_netmask: "/128"
ipv6_gateway: "2a02:6ea0:d605::1337"
filesystem: "btrfs"
network_interface: "en*"
system_disks:
  - /dev/sda
  - /dev/sdb
  - /dev/sdc
raid_level: "raid5"
