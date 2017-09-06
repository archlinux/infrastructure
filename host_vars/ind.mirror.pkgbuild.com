---
default_qdisc: "fq"
tcp_congestion_control: "bbr"

mirror_domain: ind.mirror.pkgbuild.com
