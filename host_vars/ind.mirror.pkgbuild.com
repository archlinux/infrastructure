---
mirror_domain: ind.mirror.pkgbuild.com
archweb_mirrorcheck_locations: [10]
arch32_mirror_domain: ind.mirror.archlinux32.org
network_interface: "eno2"
ipv4_address: "169.38.85.99"
ipv4_netmask: "/26"
ipv4_gateway: "169.38.85.65"

configure_firewall: true

# this is needed to make ansible find the firewalld python
# module when deploying firewalld tasks
ansible_python_interpreter: /usr/bin/python3.7
