---
mirror_domain: mex.mirror.pkgbuild.com
archweb_mirrorcheck_locations: [7]
arch32_mirror_domain: mex.mirror.archlinux32.org
network_interface: "eno2"
ipv4_address: "169.57.35.94"
ipv4_netmask: "/26"
ipv4_gateway: "169.57.35.65"

configure_firewall: true

# this is needed to make ansible find the firewalld python
# module when deploying firewalld tasks
ansible_python_interpreter: /usr/bin/python3.7
