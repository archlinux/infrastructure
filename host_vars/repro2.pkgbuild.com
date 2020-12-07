hostname: "repro2.pkgbuild.com"

ipv4_address: "212.102.38.209"
ipv4_netmask: "/24"
ipv4_gateway: "212.102.38.222"

filesystem: "btrfs"
network_interface: "en*"

system_disks:
  - /dev/sda
  - /dev/sdb
raid_level: "raid1"

rebuilderd_workers:
 - repro21
 - repro22
 - repro23
 - repro24
