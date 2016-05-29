#!/usr/bin/env bash

borg create -v --stats -C lz4 -e /proc \
    -e /sys -e /dev -e /run -e /tmp -e /var/cache \
    {{ backup_host }}:{{ backup_dir }}::$(date -I) /
borg prune -v {{ backup_host }}:{{ backup_dir }} --keep-daily=7 --keep-weekly=4 --keep-monthly=6
