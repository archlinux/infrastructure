# Quassel

We offer a Quassel instance for Arch team members who can not easily run their own bouncer.

## Libera Chat restrictions

Libera Chat restricts or limits multiple connections from the same IP Address. Every quassel user uses
a separate connection. We are currently not near the limit. If we need more we have to email
support@libera.chat.

## Add a user

`sudo -u quassel quasselcore --configdir=/var/lib/quassel --add-user`

## Migration quassel

Stop the quassel service:

`sudo -u postgres pg_dump -F c quassel >quassel.dump`

Restore the data:

`sudo -u postgres pg_restore -d quassel --clean --exit-on-error <quassel.dump`
