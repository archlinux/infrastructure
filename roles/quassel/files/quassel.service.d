[Service]
ExecStart=
ExecStart=/usr/bin/quasselcore --configdir=/var/lib/quassel --ident-daemon --ident-listen=::,0.0.0.0 --ident-port=113 --strict-ident --syslog --require-ssl
AmbientCapabilities=CAP_NET_BIND_SERVICE
PrivateTmp=yes
NoNewPrivileges=yes
ProtectSystem=full
ProtectControlGroups=yes
ProtectKernelModules=yes
ProtectKernelTunables=yes
