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

- [ ] Add user mail if TU or developer, or support staff and **communication e-mail address** is arch.
  - [ ] Add new user email as per [`docs/email.md`](docs/email.md).
  - [ ] Add entry in [`group_vars/all/archusers.yml`](group_vars/all/archusers.yml).
    - If support staff `hosts` should be set to `mail.archlinux.org`.
    - `homedir.archlinux.org` is also allowed for support staff, but it is opt-in.
  - [ ] Add SSH pubkey to `pubkeys/<username>.pub`.
  - [ ] Run `ansible-playbook -t archusers $(git grep -l archusers playbooks/ | grep -v phrik)`.
- [ ] Create a new user in [archweb](https://www.archlinux.org/devel/newuser/). Select the appropriate group membership and allowed repos (if applicable).
- [ ] Subscribe **communication e-mail address** to internal [staff mailing list](https://lists.archlinux.org/mailman3/lists/staff.lists.archlinux.org/mass_subscribe/).
- [ ] Allow sending from **communication e-mail address** on [arch-dev-public](https://lists.archlinux.org/mailman3/lists/arch-dev-public.lists.archlinux.org/members/member/) (subscribe and/or find address and remove moderation).
- [ ] Give the user access to `#archlinux-staff` on Libera Chat.
- [ ] Give the user a link to our [staff services page](https://wiki.archlinux.org/title/DeveloperWiki:Staff_Services).
- [ ] Replace the **Team member username** with the @-prefixed username on Gitlab.
- [ ] Remove personal information (such as **Full Name** and **Personal e-mail
  address**, as well as the clearsigned representation of this data), remove
  the description history and make the issue non-confidential.
- [ ] Request staff cloak on Libera Chat ([Group contacts](https://wiki.archlinux.org/title/Arch_IRC_channels#Libera_Chat_group_contacts))

## Packager onboarding checklist

<!-- The ticket should be created by a sponsor of the new packager -->
- [ ] Create [issue in archlinux-keyring using the *"New Packager Key"* template](https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/issues/new?issuable_template=New%20Packager%20Key).

## Main key onboarding checklist

- [ ] Add new user email for the `master-key.archlinux.org` subdomain as per [`docs/email.md`](docs/email.md).
  <!-- The ticket should be created by the developer becoming a new main key holder -->
- [ ] Create [issue in archlinux-keyring using the *"New Main Key"* template](https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/issues/new?issuable_template=New%20Main%20Key).

## Developer onboarding checklist

- [ ] Assign the user to the `Developers` groups on Keycloak.
- [ ] Assign the user to the `Developers` group on [archlinux.org](https://archlinux.org/admin/auth/user/).
- [ ] Subscribe **communication e-mail address** to internal [arch-dev](https://lists.archlinux.org/mailman3/lists/arch-dev.lists.archlinux.org/mass_subscribe/) mailing list.

## TU onboarding checklist

- [ ] Assign the user to the `Trusted Users` groups on Keycloak.
- [ ] Assign the user to the `Trusted Users` group on [archlinux.org](https://archlinux.org/admin/auth/user/).
- [ ] Subscribe **communication e-mail address** to internal [arch-tu](https://lists.archlinux.org/mailman3/lists/arch-tu.lists.archlinux.org/mass_subscribe/) mailing list.

## Support staff checklist

- [ ] Assign the user to the proper support staff group on Keycloak.

## DevOps onboarding checklist

- [ ] Add entries in [`group_vars/all/root_access.yml`](group_vars/all/root_access.yml).
- [ ] Run `ansible-playbook -t root_ssh playbooks/all-hosts-basic.yml`.
- [ ] Run `ansible-playbook playbooks/hetzner_storagebox.yml playbooks/rsync.net.yml`.
- [ ] Subscribe **communication e-mail address** to internal [arch-devops-private](https://lists.archlinux.org/mailman3/lists/arch-devops-private.lists.archlinux.org/mass_subscribe/) mailing list.
- [ ] Add pubkey to [Hetzner's key management](https://robot.your-server.de/key/index) for Dedicated server rescue system.

## Wiki Administrator checklist

- [ ] Subscribe **communication e-mail address** to the [arch-wiki-admins](https://lists.archlinux.org/mailman3/lists/arch-wiki-admins.lists.archlinux.org/mass_subscribe/) mailing list.
