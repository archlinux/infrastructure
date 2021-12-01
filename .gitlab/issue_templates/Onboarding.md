<!--
This template should be used for onboarding new Arch Linux team members.
It can also be used as a reference for adding new roles to an existing team member.
-->
/confidential
<!--
NOTE: Do not remove the above short actions.
They ensure that the ticket is created confidential and that personal
information is not publicly visible.
-->

# Onboarding an Arch Linux team member

## Details

- **Team member username**: <!-- Used for SSO account and @archlinux.org e-mail address -->
- **Application**: <!-- Add link to relevant mailing list mail -->
- **Voting result**: <!-- Add link to relevant mailing list mail -->
- **SSH public key**: <!-- Add this when a user's access to machines is added or updated -->
- **Full Name**: <!-- Relevant for all new users -->
- **Personal e-mail address**: <!-- Relevant for users who will get a new archweb and/or SSO account -->
- **PGP key ID used with personal e-mail address**: <!-- Relevant for users who will get a new archweb account -->
- **Communication e-mail address**: [arch, personal] <!-- Relevant for users who will be signed up to mailing lists. Either choose "arch" or "personal". -->

<!--
NOTE: When creating this ticket as the sponsor for a new trusted user or
support staff member, attach the above information as a clearsigned document to
this ticket.
https://www.gnupg.org/gph/en/manual/x135.html
-->

## All roles checklist
The mailing list password can be found in misc/additional-credentials.vault.

- [ ] Add new user email as per `docs/email.md`.
- [ ] Create a new user in [archweb](https://www.archlinux.org/devel/newuser/). Select the appropriate group membership and allowed repos (if applicable).
- [ ] Subscribe **communication e-mail address** to internal [staff mailing list](https://lists.archlinux.org/admin/staff/members/add).
- [ ] Give the user access to `#archlinux-staff` on Libera Chat.
- [ ] Give the user a link to our [staff services page](https://wiki.archlinux.org/title/DeveloperWiki:Staff_Services).
- [ ] Replace the **Team member username** with the @-prefixed username on Gitlab.
- [ ] Remove personal information (such as **Full Name** and **Personal e-mail
  address**, as well as the clearsigned representation of this data), remove
  the description history and make the issue non-confidential.
- [ ] Request staff cloak on Libera Chat ([Group contacts](https://wiki.archlinux.org/title/Arch_IRC_channels#Libera_Chat_group_contacts))

## Packager onboarding checklist

<!-- The ticket should be created by a sponsor of the new packager -->
- [ ] Create [issue in archlinux-keyring](https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/issues/new) (choose *"New Packager Key"* template).

## Main key onboarding checklist

- [ ] Add new user email for the `master-key.archlinux.org` subdomain as per `docs/email.md`.
<!-- The ticket should be created by the developer becoming a new main key holder -->
- [ ] Create [issue in archlinux-keyring](https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/issues/new) (choose *"New Main Key"* template).

## Developer onboarding checklist

- [ ] Add entry in `group_vars/all/archusers.yml`.
- [ ] Add SSH pubkey to `pubkeys/<username>.pub`.
- [ ] Run `ansible-playbook -t archusers playbooks/*.yml`.
- [ ] Assign the user to the `Developers` groups on Keycloak.
- [ ] Assign the user to the `Developers` group on [archlinux.org](https://archlinux.org/admin/auth/user/).
- [ ] Subscribe **communication e-mail address** to internal [arch-dev](https://lists.archlinux.org/admin/arch-dev/members/add) mailing list.
- [ ] Allow sending from **communication e-mail address** on [arch-dev-public](https://lists.archlinux.org/admin/arch-dev-public/members) (subscribe and/or find address and remove moderation).

## TU onboarding checklist

- [ ] Add entry in `group_vars/all/archusers.yml`.
- [ ] Add SSH pubkey to `pubkeys/<username>.pub`.
- [ ] Run `ansible-playbook -t archusers playbooks/*.yml`.
- [ ] Assign the user to the `Trusted Users` groups on Keycloak.
- [ ] Assign the user to the `Trusted Users` group on [archlinux.org](https://archlinux.org/admin/auth/user/).
- [ ] Subscribe **communication e-mail address** to internal [arch-tu](https://lists.archlinux.org/admin/arch-tu/members/add) mailing list.
- [ ] Allow sending from **communication e-mail address** on [arch-dev-public](https://lists.archlinux.org/admin/arch-dev-public/members) (subscribe and/or find address and remove moderation).

## DevOps onboarding checklist

- [ ] Add entries in `group_vars/all/root_access.yml`.
- [ ] Run `ansible-playbook -t root_ssh playbooks/all-hosts-basic.yml`.
- [ ] Run `ansible-playbook playbooks/hetzner_storagebox.yml playbooks/rsync.net.yml`.
- [ ] Assign the user to the `DevOps` group on Keycloak.
- [ ] Subscribe **communication e-mail address** to internal [arch-devops-private](https://lists.archlinux.org/admin/arch-devops-private/members/add) mailing list.
- [ ] Add pubkey to [Hetzner's key management](https://robot.your-server.de/key/index) for Dedicated server rescue system.

## Wiki Administrator checklist

- [ ] Assign the user to the `Wiki Admins` group on Keycloak.
- [ ] Subscribe **communication e-mail address** to the [arch-wiki-admins](https://lists.archlinux.org/admin/arch-wiki-admins/members/add) mailing list.
