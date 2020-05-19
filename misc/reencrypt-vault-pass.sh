#!/bin/sh
set -e

cd -- "$(dirname $0)"

recipients=""
for key in vault-keys/*.gpg; do
    recipients="$recipients --recipient-file $key"
done

if [ -n "$1" ]; then
    echo >&2 "WARNING: Using argument as vault password"
    echo -n "$1"
else
    gpg --batch --decrypt --quiet vault-password.gpg
fi | gpg --batch --encrypt --quiet $recipients -o vault-password-new.gpg
mv vault-password-new.gpg vault-password.gpg
