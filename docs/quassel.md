# Quassel

We offer a Quassel instance for Arch team members who can not easily run their own bouncer.

## Freenode restrictions

Freenode restricts or limits multiple connections from the same IP Address. Every quassel user uses
a separate connection. We current have a limit of 100 connections. If we need more we have to email
ilines@freenode.net.

## Add a user

1. `sudo -u quassel quasselcore --configdir=/var/lib/quassel --add-user`

## Migration quassel

1. `Stop the quassel service`
2. `sudo -u postgres pg_dump -F c quassel >quassel.dump`
3. `sudo -u postgres pg_restore -d quassel --clean --exit-on-error <quassel.dump`
