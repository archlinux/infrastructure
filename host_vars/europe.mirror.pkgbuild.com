hostname: "europe.mirror.pkgbuild.com"

ipv4_address: "89.187.191.12"
ipv4_netmask: "/26"
ipv4_gateway: "89.187.191.62"
filesystem: "btrfs"
network_interface: "en*"
system_disks:
  - /dev/sda
  - /dev/sdb
  - /dev/sdc
raid_level: "raid5"
