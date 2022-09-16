# Keys

This directory contains the GPG master and signing keys used by the following projects:
- [Renovate](https://gitlab.archlinux.org/archlinux/renovate/renovate) for signing commits
- [arch-boxes](https://gitlab.archlinux.org/archlinux/arch-boxes) for signing releases

The Renonvate keys were generated with the following commands:
```sh
$ export GNUPGHOME="$(mktemp -d)"
$ gpg --quick-generate-key 'renovate <renovate@archlinux.org>' rsa4096 cert never
$ key_id="$(gpg --with-colons --list-keys renovate@archlinux.org | awk -F : '$1 == "fpr" {print $10;exit}')"
$ gpg --quick-add-key "${key_id}" rsa4096 sign 5y
$ gpg --armor --export-secret-keys "${key_id}"
$ gpg --armor --export-secret-subkeys "${key_id}"
$ rm -r "${GNUPGHOME}"
```

The arch-boxes keys were generated with the following commands:
```sh
$ export GNUPGHOME="$(mktemp -d)"
$ gpg --quick-generate-key 'arch-boxes <arch-boxes@archlinux.org>' ed25519 cert never
$ key_id="$(gpg --with-colons --list-keys arch-boxes@archlinux.org | awk -F : '$1 == "fpr" {print $10;exit}')"
$ gpg --quick-add-key "${key_id}" ed25519 sign 5y
$ gpg --armor --export-secret-keys "${key_id}"
$ gpg --armor --export-secret-subkeys "${key_id}"
$ rm -r "${GNUPGHOME}"
```

The exported signing keys have been added as GitLab CI/CD variables to the projects. The master keys and a copy of the signing keys are stored in the [`renovate.asc`](renovate.asc) and [`arch-boxes.asc`](arch-boxes.asc) file.
