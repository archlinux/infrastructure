# Becoming Arch Linux DevOps

In Arch Linux, DevOps are expected to be reliable, trusthworthy, and self-directed.
DevOps should be known and trusted by the community beforehand or be recommended by previous
members.

## Junior DevOps program

In order to become a full DevOps, the applicant must first join the Junior DevOps program. This
program requires applicants to

0) have contributed to Arch multiple times in some meaningful ways,
1) find two sponsors, and
2) write an application to the arch-devops mailing list.

The idea of Junior DevOps is that they don't get full access to all secrets and machines as opposed
to full DevOps but access within the limited scope on which they have been assigned rights to work
on. As trust grows the scope on which the Junior DevOps operates may be extended, while their
sponsors are expected to help them learn and should feel responsible to review any meaningful
changes.

However, Junior DevOps can already help with many tasks and are expected to take charge of a given
topic.

After a lot of trust is built up, Junior DevOps may graduate to become full DevOps. This usually
takes 3-9 months.

## Onboarding

### OpenPGP Keys

The `root_access.yml` file contains the `vault_default_pgpkeys` variable which
determines the users that have access to the `default` vault, as well as the
borg backup keys. A separate `super` vault exists for storing highly sensitive
secrets like Hetzner credentials; access to the `super` vault is controlled by
the `vault_super_pgpkeys` variable.

All the keys should be on the local user gpg keyring and at **minimum** be
locally signed with `--lsign-key` (or if you use TOFU, have `--tofu-policy
good`). This is necessary for running any of the `reencrypt-vault-default-key`,
`reencrypt-vault-super-key` or `fetch-borg-keys` tasks.

### Re-encrypting the vaults after adding a new PGP key

Follow the instructions in [`group_vars/all/root_access.yml`](group_vars/all/root_access.yml).

### Changing the vault password on encrypted files

See [docs/vault-rekeying.md](docs/vault-rekeying.md).
