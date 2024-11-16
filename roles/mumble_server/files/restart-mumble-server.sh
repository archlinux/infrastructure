#!/bin/bash
if [[ "$1" == "renew" ]]; then
  systemctl restart mumble-server
elif [[ "$1" == "post" ]]; then
  install -v -o _mumble-server -g _mumble-server -m 640 /etc/letsencrypt/live/mumble.archlinux.org/cert.pem /var/lib/mumble-server/cert.pem
  install -v -o _mumble-server -g _mumble-server -m 640 /etc/letsencrypt/live/mumble.archlinux.org/privkey.pem /var/lib/mumble-server/privkey.pem
  install -v -o _mumble-server -g _mumble-server -m 640 /etc/letsencrypt/live/mumble.archlinux.org/fullchain.pem /var/lib/mumble-server/fullchain.pem
fi
