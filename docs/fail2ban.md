# fail2ban

Fail2Ban is an intrusion prevention software framework that protects computer servers from brute-force attacks.

By default all our servers playbook should include the `fail2ban` role which enables the `sshd` jail by default through `groups_vars`. The default `/etc/fail2ban/jail.local` configuration whitelists all the servers in `hosts`, take note that when adding a new postfix relayhost the `fail2ban` role has to be run on the postfix server to update the whitelist.

## Jails

Fail2ban can provide multiple jails for different services, to check the status of for example the `sshd` jail:

```
fail2ban-client status sshd
```

To unblock an IP Address:

```
fail2ban-client set sshd unbanip 8.8.8.8
```

### sshd

The sshd jail should be enabled for every host we have, to block brute force ssh attacks.

### postfix

The postfix jail not enabled on any server. Adding it to a host:

Add `fail2ban_jails` dict with `postfix: true` to the host's `host_vars`.

### dovecot

The dovecot jail is enabled for our mail server, blocking failed logins. Adding it to a host:

Add `fail2ban_jails` dict with `dovecot: true` to the host's `host_vars`.

### nginx_limit_req

The nginx_limit_req jail is not enabled on any server. This jail bans IPs based repeated errors on nginx error log. Default blocking is 1 hour(s). Adding to a host:

Add `fail2ban_jails` dict with `nginx_limit_req: true` to the host's `host_vars`.

The `rsslimit` zone is whitelisted from being banned with `ignoreregex`, as we
choose to not ban RSS abusers.
