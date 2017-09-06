---
default_qdisc: "fq"
tcp_congestion_control: "bbr"

mirror_domain: jpn.mirror.pkgbuild.com
