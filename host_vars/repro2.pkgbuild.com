hostname: "repro2.pkgbuild.com"

ipv4_address: "212.102.38.209"
ipv4_netmask: "/24"
ipv4_gateway: "212.102.38.222"
ipv6_address: "2a02:6ea0:c238::2"
ipv6_netmask: "/128"
ipv6_gateway: "2a02:6ea0:c238::1337"

filesystem: "btrfs"
network_interface: "enp65s0f0"

system_disks:
  - /dev/sda
  - /dev/sdb
raid_level: "raid1"

rebuilderd_workers:
 - repro21
 - repro22
 - repro23
 - repro24
