hostname: "america.mirror.pkgbuild.com"
archive_domain: "america.archive.pkgbuild.com"
ipv4_address: "143.244.34.62"
ipv4_netmask: "/25"
ipv4_gateway: "143.244.34.126"
ipv6_address: "2a02:6ea0:cc0e::2"
ipv6_netmask: "/128"
ipv6_gateway: "2a02:6ea0:cc0e::1337"
filesystem: "btrfs"
network_interface: "en*"
system_disks:
  - /dev/sda
  - /dev/sdb
  - /dev/sdc
raid_level: "raid5"
