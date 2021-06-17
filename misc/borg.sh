#!/bin/bash

set -eu
shopt -s extglob

OFFSITE_HOST=ch-s012.rsync.net

decrypted_gpg=$(mktemp arch-infrastructure-borg-XXXXXXXXX)
trap "rm -f \"${decrypted_gpg}\"" EXIT
[[ "$*" =~ $OFFSITE_HOST ]] && is_offsite=true || is_offsite=false

# Find matching key
matching_key=""
for gpgkey in borg-keys/!(*-offsite.gpg); do
    key=$(basename "$gpgkey" .gpg)
    if [[ "$*" =~ $key ]]; then
        matching_key="$key"
        if $is_offsite; then
            matching_key=$matching_key-offsite
        fi
    fi
done

if [[ -z "$matching_key" ]]; then
    echo "No matching keyfile found for this host"
    exit 1
fi
gpg --batch --yes --decrypt -aq --output "$decrypted_gpg" borg-keys/"$matching_key.gpg"

BORG_KEY_FILE="$decrypted_gpg" borg "$@"

rm "$decrypted_gpg"
