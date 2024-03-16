#!/bin/bash

# crt.sh lookup script to generate part of the blackbox_targets.http_prometheus
# list (stored in roles/prometheus/defaults/main.yml) based on SSL certificates

set -eo pipefail

readonly DOMAINS=(
  archlinux.org
  pkgbuild.com
  archlinux.page
)
readonly LOOKUP_URLS=(
  "${DOMAINS[@]/#/https://crt.sh/?exclude=expired\&deduplicate=Y\&output=json\&q=}"
)

names() {
  curl -sf "${LOOKUP_URLS[@]}" | jq -r '.[].name_value' | sort -u
}

prometheus_targets() {
  names \
  | sed 's|^|https://|' \
  | sed '/monitoring\|dashboards/ s|$|/healthz|' \
  | sed '/mta-sts/ s|$|/.well-known/mta-sts.txt|' \
  | sed '/openpgpkey/ s|openpgpkey\.\(.*\)|&/.well-known/openpgpkey/\1/policy|' \
  | sed '/repos\.arch/ s|$|/lastupdate|' \
  | sed '/static\.conf/ s|$|/README.md|' \
  | sed -r '/(geo|riscv)\.mirror|(bugs-old|coc|git|status)\.arch/d' \
  | xargs -P8 -I{} sh -c 'curl -m 10 -sf -o /dev/null {} && echo "    "- {}' \
  | sort
}

if [[ $1 = targets ]]; then
  prometheus_targets
elif [[ -n $1 ]]; then
  echo >&2 'error: the first argument can only be empty or "targets"'
  exit 1
else
  names
fi
