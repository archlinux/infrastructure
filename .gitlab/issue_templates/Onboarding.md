<!--
This template should be used for onboarding new Arch Linux team members.
It can also be used as a reference for adding new roles to an existing team member.
-->

# Onboarding an Arch Linux team member

## Details

- **Team member username**:

## All roles checklist

- [ ] Add new user email as per `docs/email.md`.
- [ ] Create a new user in archweb: https://www.archlinux.org/devel/newuser/
      This is also linked in the django admin backend at the top

## TU/Developer onboarding checklist

- [ ] Add entry in `group_vars/all/archusers.yml`.
- [ ] Add SSH pubkey to `pubkeys/<username>.pub`.
- [ ] Run `ansible-playbook -t archusers playbooks/*.yml`.
- [ ] Assign the user to the `Trusted Users`/`Developers` groups on Keycloak.

## DevOps onboarding checklist

- [ ] Add entries in `group_vars/all/root_access.yml`.
- [ ] Run `ansible-playbook -t root_ssh playbooks/*.yml`.
- [ ] Run `ansible-playbook playbooks/hetzner_storagebox.yml playbooks/rsync.net.yml`.
- [ ] Assign the user to the `DevOps` group on Keycloak.
- [ ] Add the user to the `arch-devops-private` mailing list.

## Wiki Administrator checklist

- [ ] Assign the user to the `Wiki Admins` group on Keycloak.
