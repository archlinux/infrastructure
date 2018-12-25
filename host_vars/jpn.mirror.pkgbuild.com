---
mirror_domain: jpn.mirror.pkgbuild.com
archweb_mirrorcheck_locations: [8]
arch32_mirror_domain: jpn.mirror.archlinux32.org
network_interface: "eno2"
ipv4_address: "161.202.225.107"
ipv4_netmask: "/26"
ipv4_gateway: "161.202.225.65"

configure_firewall: true

# this is needed to make ansible find the firewalld python
# module when deploying firewalld tasks
ansible_python_interpreter: /usr/bin/python3.7
