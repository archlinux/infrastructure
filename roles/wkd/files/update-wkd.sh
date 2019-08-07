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

for email in $(gpg --list-options show-only-fpr-mbox --list-keys | grep '@archlinux.org' | cut -d' ' -f2); do
	wkd_hash="$(/usr/lib/gnupg/gpg-wks-client --print-wkd-hash "$email" | cut -d' ' -f1)"
	outfile="$workdir/openpgpkey/archlinux.org/hu/$wkd_hash"
	gpg --export "$email" > "$outfile"

	# TODO: return error if filesize of $outfile is >= 64kB; https://dev.gnupg.org/T4607#127792
done
