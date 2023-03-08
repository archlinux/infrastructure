<!--
This template should be used for offboarding Arch Linux team members.
-->

# Offboarding an Arch Linux team member

## Details

- **Team member username**:
- **Currently held roles**: <!-- Add known roles here like TU, DevOps, etc -->
- **Removal request**: <!-- Add link to relevant mailing list mail -->
  - **Voting result**: <!-- Add link to relevant mailing list mail -->

## All roles checklist

- [ ] Remove user email by reverting instructions from [`docs/email.md`](docs/email.md).
  - [ ] Remove entry in [`group_vars/all/archusers.yml`](group_vars/all/archusers.yml).
  - [ ] Remove SSH pubkey from `pubkeys/<username>.pub`.
  - [ ] Run `ansible-playbook -t archusers  $(git grep -l archusers playbooks/ | grep -v phrik)`.
  - [ ] Setup forwarding if requested (please add the current date as a comment above the mail address in Postfix's `users` file).
    - [ ] Inform the user of the conditions for forwarding.
      - In most cases we only offer forwarding for 6 months.
      - We will inform the user prior to disabling the forwarding.
      - The forwarding can be extended if there are good reasons for doing so.
- [ ] Set user to inactive in archweb: https://www.archlinux.org/admin/auth/user/
- [ ] Remove member from [staff mailing list](https://lists.archlinux.org/mailman3/lists/staff.lists.archlinux.org/members/member/).
- [ ] Moderate email address on [arch-dev-public](https://lists.archlinux.org/mailman3/lists/arch-dev-public.lists.archlinux.org/members/member/) (find member and moderate).
- [ ] Ask the user to leave `#archlinux-staff` on Libera Chat and forget the password.
- [ ] Remove staff cloak on Libera Chat ([Group contacts](https://wiki.archlinux.org/title/Arch_IRC_channels#Libera_Chat_group_contacts)).
- [ ] Remove the user from relevant staff groups on Keycloak.

## Main key offboarding checklist

- [ ] Remove user email for the `master-key.archlinux.org` subdomain by reverting instructions from [`docs/email.md`](docs/email.md).
- [ ] Create an issue in [archlinux-keyring](https://gitlab.archlinux.org/archlinux/archlinux-keyring) using the [*"Remove Main Key"*](https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/issues/new?issuable_template=Remove%20Main%20Key) template.

## TU/Developer offboarding checklist

- [ ] Remove member from [arch-tu](https://lists.archlinux.org/mailman3/lists/arch-tu.lists.archlinux.org/members/member/) and/or [arch-dev](https://lists.archlinux.org/mailman3/lists/arch-dev.lists.archlinux.org/members/member/) mailing lists.
- [ ] Ask the user to leave `#archlinux-tu` and/or `#archlinux-dev` on Libera Chat and forget the password(s).
- [ ] Create an issue in [archlinux-keyring](https://gitlab.archlinux.org/archlinux/archlinux-keyring) using the [*"Remove Packager Key"*](https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/issues/new?issuable_template=Remove%20Packager%20Key) template.
- [ ] Remove the user from the public list on archweb ([TUs](https://archlinux.org/people/trusted-users/)/[devs](https://archlinux.org/people/developers/)) and add them as fellow ([fellow TUs](https://archlinux.org/people/trusted-user-fellows/)/[fellow devs](https://archlinux.org/people/developer-fellows/))

## DevOps offboarding checklist

- [ ] Remove entries in [`group_vars/all/root_access.yml`](group_vars/all/root_access.yml).
- [ ] Run `ansible-playbook -t root_ssh playbooks/all-hosts-basic.yml`.
- [ ] Run `ansible-playbook playbooks/hetzner_storagebox.yml playbooks/rsync.net.yml`.
- [ ] Remove member from [arch-devops-private mailing lists](https://lists.archlinux.org/mailman3/lists/arch-devops-private.lists.archlinux.org/members/member/).
- [ ] Remove pubkey from [Hetzner's key management](https://robot.your-server.de/key/index).

## Wiki Administrator checklist

- [ ] Remove member from [arch-wiki-admins mailing list](https://lists.archlinux.org/mailman3/lists/arch-wiki-admins.lists.archlinux.org/members/member/).
