# Configuration for users

SMTP/IMAP server: mail.archlinux.org
SMTP port: 465 (TLS), [deprecated: 587 STARTTLS]
IMAP port: 993 (TLS)

username: the system account name
password: set by each user themselves with `passwd` on mail.archlinux.org

# Adding new archlinux.org email addresses

Login to mail.archlinux.org and edit `/etc/postfix/users`, add the new email address in the
appropriate category and run `postmap /etc/postfix/users`.

If the user wants to forward email, either enter the destination directly in
the /etc/postfix/users file or enter a username and then put the destination
into `~username/.forward` so that they can edit it themselves.

# SMTP Architecture

All hosts should be relaying outbound SMTP traffic via our primary MX server
(currently 'mail.archlinux.org'). Each hosts authenticates using SASL over a TLS connection
to the server. This gives us several benefits:

1. DKIM signing can be done centrally.
2. SPF records require less maintenance as servers are added/removed.
3. Our email reputation is focused on one well-maintained and (hopefully) well
   maintained host, rather than distributed across all hosts in our fleet.
4. Central traceability for debugging.
5. Central maintainability for rate-limiting to prevent abuse.

When a new host is provisioned:

- The *postfix* role has a task delegated to 'mail.archlinux.org' to create a local user
  on 'mail.archlinux.org' that is used for the new server to authenticate against. The user
  name is the shortname of the new servers hostname (ie, "foobar.archlinux.org"
  will authenticate with the username "foobar")
- You will need to run the *postfwd* role against mail.archlinux.org to update the
  rate-limiting it performs (servers are given higher rate-limits than normal
  users - see `/etc/postfwd/postfwd.cf` for exact limits). This *should*
  happen automatically as the *postfwd* role is a dependency of the *postfix*
  role (using `delegate_to` to run it against 'mail.archlinux.org' regardless of the target
  host that the postfix role is being run on)

# Create new DKIM keys

The rspamd role expects the key to exist in the vault. To generate new keys, run
```
rspamadm dkim_keygen -s dkim-ed25519 -b 0 -d archlinux.org -t ed25519 -k archlinux.org.dkim-ed25519.key
rspamadm dkim_keygen -s dkim-rsa -b 4096 -d archlinux.org -t rsa -k archlinux.org.dkim-rsa.key
```
the ouput gives you the DNS entries to add to the terraform files.
The keys generated need to go to the vault:
```
roles/rspamd/files/archlinux.org.dkim-rsa.key
roles/rspamd/files/archlinux.org.dkim-ed25519.key
```

# Gitlab servicedesk

Gitlab has a [servicedesk
feature](https://docs.gitlab.com/ee/user/project/service_desk.html) which
creates issues for incomding emails and allows multiple people to reply via
Gitlab on those issues and assign issues. Gitlab generates a default email
address with the following logic:

```
gitlab+<group>-<project>-<project-id>-issue-@archlinux.org
```

As we prefer to use user friendly addresses such as `privacy@archlinux.org` for communication a postfix alias is configured in `/etc/postix/aliases`.

For a new Gitlab service desk project, add a new alias to `/etc/postfix/aliases` as:

```
foobar: gitlab+<group>-<project>-<project-id>-issue-@archlinux.org
```

Then run `postalias`:

```
postalias /etc/postfix/aliases
```
