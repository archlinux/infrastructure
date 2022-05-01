# Keys

This directory contains the GPG master and signing key used by [Renovate](https://github.com/renovatebot/renovate) for signing its commits.

The keys were generated with the following commands:
```sh
$ export GNUPGHOME="$(mktemp -d)"
$ gpg --quick-generate-key 'renovate <renovate@archlinux.org>' rsa4096 cert never
$ key_id="$(gpg --with-colons --list-keys renovate@archlinux.org | awk -F : '$1 == "fpr" {print $10;exit}')"
$ gpg --quick-add-key "${key_id}" rsa4096 sign 5y
$ gpg --armor --export-secret-keys "${key_id}"
$ gpg --armor --export-secret-subkeys "${key_id}"
$ rm -r "${GNUPGHOME}"
```

The exported signing key has been added as a GitLab CI/CD variable to the [renovate project](https://gitlab.archlinux.org/archlinux/renovate/renovate). The master and and a copy of the signing key are stored in the [`renovate.asc`](renovate.asc) file.
