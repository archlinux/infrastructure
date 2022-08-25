#!/bin/sh

readonly vault_password_file_encrypted="$(dirname $0)/vault-$2-password.gpg"

# flock used to work around "gpg: decryption failed: No secret key" in tf-stage2
# would otherwise need 'auto-expand-secmem' (https://dev.gnupg.org/T3530#106174)
flock "$vault_password_file_encrypted" \
  gpg --batch --decrypt --quiet "$vault_password_file_encrypted"
