#!/bin/bash

set -o nounset -o errexit

if (( $# < 1 )); then
    echo "Missing argument"
    exit 0
fi

if [[ -z "$FASTLY_API_TOKEN" ]]; then
    echo "'\$FASTLY_API_TOKEN' is empty"
    exit 0
fi

FASTLY_MIRROR_URL="https://fastly.mirror.pkgbuild.com"

repo=$1

URLS=(
    "${FASTLY_MIRROR_URL}/${repo}/os/x86_64/${repo}.db"
    "${FASTLY_MIRROR_URL}/${repo}/os/x86_64/${repo}.db.tar.gz"
    "${FASTLY_MIRROR_URL}/${repo}/os/x86_64/${repo}.db.tar.gz.old"

    "${FASTLY_MIRROR_URL}/${repo}/os/x86_64/${repo}.files"
    "${FASTLY_MIRROR_URL}/${repo}/os/x86_64/${repo}.files.tar.gz"
    "${FASTLY_MIRROR_URL}/${repo}/os/x86_64/${repo}.files.tar.gz.old"

    "${FASTLY_MIRROR_URL}/${repo}/os/x86_64/${repo}.links"
)

for URL in "${URLS[@]}"; do
    echo "Purging URL '${URL}'"
    curl --silent --show-error --fail -X PURGE -H @<(echo Fastly-Key: "${FASTLY_API_TOKEN}") "${URL}"
done
