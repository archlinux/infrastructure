hostname: "america.mirror.pkgbuild.com"
ipv4_address: "143.244.34.62"
ipv4_netmask: "/25"
ipv4_gateway: "143.244.34.126"
filesystem: "btrfs"
network_interface: "en*"
system_disks:
  - /dev/sda
  - /dev/sdb
  - /dev/sdc
raid_level: "raid5"
