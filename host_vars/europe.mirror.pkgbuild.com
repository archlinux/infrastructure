hostname: "europe.mirror.pkgbuild.com"
archive_domain: "europe.archive.pkgbuild.com"
mirror_domain: "europe.mirror.pkgbuild.com"
ipv4_address: "89.187.191.12"
ipv4_netmask: "/26"
ipv4_gateway: "89.187.191.62"
ipv6_address: "2a02:6ea0:c237::2"
ipv6_netmask: "/128"
ipv6_gateway: "2a02:6ea0:c237::1337"
filesystem: "btrfs"
network_interface: "enp1s0f1"
system_disks:
  - /dev/sda
  - /dev/sdb
  - /dev/sdc
raid_level: "raid5"
