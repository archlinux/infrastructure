---
mirror_domain: sgp.mirror.pkgbuild.com
archweb_mirrorcheck_locations: [9]
arch32_mirror_domain: sgp.mirror.archlinux32.org
archbuild_fs: 'btrfs'
network_interface: "eno2"
ipv4_address: "161.202.204.205"
ipv4_netmask: "/26"
ipv4_gateway: "161.202.204.193"

configure_firewall: true

# this is needed to make ansible find the firewalld python
# module when deploying firewalld tasks
ansible_python_interpreter: /usr/bin/python3.7
