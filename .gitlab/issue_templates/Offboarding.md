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

- [ ] Remove user email by reverting instructions from `docs/email.md`.
- [ ] Set user to inactive in archweb: https://www.archlinux.org/admin/auth/user/
- [ ] Remove member from [staff mailing list](https://lists.archlinux.org/admin/staff/members)
- [ ] Ask the user to leave `#archlinux-staff` on Libera Chat and forget the password
- [ ] Remove staff cloak on Libera Chat ([Group contacts](https://wiki.archlinux.org/title/Arch_IRC_channels#Libera_Chat_group_contacts))

## TU/Developer offboarding checklist

- [ ] Remove entry in `group_vars/all/archusers.yml`.
- [ ] Remove SSH pubkey from `pubkeys/<username>.pub`.
- [ ] Run `ansible-playbook -t archusers  $(git grep -l archusers playbooks/ | grep -v phrik)`.
- [ ] Remove the user from the `Trusted Users`/`Developers` groups on Keycloak.
- [ ] Moderate email address on [arch-dev-public](https://lists.archlinux.org/admin/arch-dev-public/members) (find member and moderate)
- [ ] Remove member from [arch-tu](https://lists.archlinux.org/admin/arch-tu/members) and/or [arch-dev](https://lists.archlinux.org/admin/arch-dev/members) mailing lists
- [ ] Create [issue in archlinux-keyring](https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/issues/new) (choose *"Remove Packager Key"* and/or *"Remove Main Key"* template)

## DevOps offboarding checklist

- [ ] Remove entries in `group_vars/all/root_access.yml`.
- [ ] Run `ansible-playbook -t root_ssh playbooks/*.yml`.
- [ ] Run `ansible-playbook playbooks/hetzner_storagebox.yml playbooks/rsync.net.yml`.
- [ ] Remove the user from the `DevOps` group on Keycloak.
- [ ] Remove member from [arch-devops-private mailing lists](https://lists.archlinux.org/admin/arch-devops-private/members)
- [ ] Remove pubkey from [Hetzner's key management](https://robot.your-server.de/key/index)

## Wiki Administrator checklist

- [ ] Remove the user from the `Wiki Admins` group on Keycloak.
- [ ] Remove member from [arch-wiki-admins mailing list](https://lists.archlinux.org/admin/arch-wiki-admins/members).
