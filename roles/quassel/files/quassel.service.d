[Service]
ExecStartPre=/bin/sh -c 'echo "global { hide }" > /var/lib/quassel/.oidentd.conf'
ExecStart=
ExecStart=/usr/bin/quasselcore --configdir=/var/lib/quassel --oidentd --oidentd-strict --syslog --require-ssl
