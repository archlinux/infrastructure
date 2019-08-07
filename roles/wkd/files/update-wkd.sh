#!/bin/bash

set -euo pipefail

workdir="$1"

if [[ -z "$workdir" ]]; then
	echo "Error: workdir not set" >&2
	exit 1
fi

export GNUPGHOME=/etc/pacman.d/gnupg

mkdir -p "$workdir/openpgpkey/archlinux.org/hu"

# Required file according to https://tools.ietf.org/html/draft-koch-openpgp-webkey-service-08#section-4.5
touch "$workdir/openpgpkey/archlinux.org/policy"

gpg --quiet --no-permission-warning --list-options show-only-fpr-mbox --list-keys | grep '@archlinux.org' | \
while read -a fpr_email; do
	if ! grep -q "${fpr_email[0]}" /usr/share/pacman/keyrings/archlinux-revoked; then
		wkd_hash="$(/usr/lib/gnupg/gpg-wks-client --print-wkd-hash "${fpr_email[1]}" | cut -d' ' -f1)"
		outfile="$workdir/openpgpkey/archlinux.org/hu/$wkd_hash"
		gpg --no-permission-warning --export --export-options export-clean,no-export-attributes "${fpr_email[0]}" > "$outfile"
	fi
done
