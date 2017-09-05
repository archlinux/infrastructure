---
default_qdisc: "fq"
tcp_congestion_control: "bbr"

mirror_domain: mex.mirror.pkgbuild.com
