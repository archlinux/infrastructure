<!--
This template should be used for offboarding Arch Linux team members.
-->

# Offboarding an Arch Linux team member

## Details

- **Team member username**:
- **Currently held roles**: <!-- Add known roles here like TU, DevOps, etc -->

## All roles checklist

- [ ] Remove user email by reverting instructions from `docs/email.md`.
- [ ] Set user to inactive in archweb: https://www.archlinux.org/admin/auth/user/

## TU/Developer offboarding checklist

- [ ] Remove entry in `group_vars/all/archusers.yml`.
- [ ] Remove SSH pubkey from `pubkeys/<username>.pub`.
- [ ] Run `ansible-playbook -t archusers playbooks/*.yml`.
- [ ] Remove the user from the `Trusted Users`/`Developers` groups on Keycloak.

## DevOps offboarding checklist

- [ ] Remove entries in `group_vars/all/root_access.yml`.
- [ ] Run `ansible-playbook -t root_ssh playbooks/*.yml`.
- [ ] Run `ansible-playbook playbooks/hetzner_storagebox.yml playbooks/rsync.net.yml`.
- [ ] Remove the user from the `DevOps` group on Keycloak.
