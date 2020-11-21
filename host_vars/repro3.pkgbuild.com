---
hostname: "repro3.pkgbuild.com"

ipv4_address: "147.75.81.79"
ipv4_netmask: "/31"
ipv6_address: "2604:1380:2001:4500::1"
ipv6_netmask: "/127"
ipv4_gateway: "147.75.81.78"
ipv6_gateway: "2604:1380:2001:4500::2"
filesystem: "btrfs"
network_interface: "enp1s0f0np0"
system_disks:
  - /dev/sda
configure_network: true
