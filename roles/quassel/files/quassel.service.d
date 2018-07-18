[Service]
ExecStart=
ExecStart=/usr/bin/quasselcore --configdir=/var/lib/quassel --ident-daemon --ident-port=1114 --strict-ident --syslog --require-ssl
