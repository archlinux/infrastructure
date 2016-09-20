#!/bin/sh
for f in /etc/letsencrypt/hook.d/*; do
  if test -x "$f"; then
    "$f" "$@"
  fi
done
