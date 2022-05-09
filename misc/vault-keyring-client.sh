#!/bin/sh

readonly vault_password_file_encrypted="$(dirname $0)/vault-$2-password.gpg"

# often getting "gpg: decryption failed: No secret key" in tf-stage2
# seems to work with flock (issue last reproduced with gnupg 2.2.35)
flock "$vault_password_file_encrypted" \
  gpg --batch --decrypt --quiet "$vault_password_file_encrypted"
