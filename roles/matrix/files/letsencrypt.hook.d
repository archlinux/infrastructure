#!/bin/sh

test "$1" = renew || exit 0

systemctl try-reload-or-restart turnserver
