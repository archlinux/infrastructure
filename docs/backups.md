# Backups

Backups should be checked now and then. Some common tasks are listed below.
You'll have to get the correct username from the vault.

## Accessing backup hosts

We use two different borg backup hosts: A primary one and an offsite one.
The URL format for the primary one is

    ssh://<hetzner_storagebox_username>@u236610.your-storagebox.de:23/~/backup/<hostname>/repo

while for the offsite one it's

    ssh://<rsync_net_username>@zh1905.rsync.net:22/~/backup/<hostname>

In the examples below, we'll just abbreviate the full address as `<backup_address>`.
If you want to use one of the examples below, you'll have to fill in the
placeholder with your desired full address to the backup repository. For instance,

    misc/borg.sh list <backup_address>::20191127-084357

becomes

    misc/borg.sh ssh://<hetzner_storagebox_username>@u236610.your-storagebox.de:23/~/backup/homedir.archlinux.org/repo::20191127-084357

A convenience wrapper script is available at `misc/borg.sh` which makes sure you
use the correct keyfile for the given server.

## Listing backups in repository

This allows you to check which backups are currently available for the given server:

    misc/borg.sh list <backup_address>

## Listing files in a specific backup

Once you figured out which backup you want to use, you can list the files inside via:

    misc/borg.sh list <backup_address>::<archive_name>

## Getting info for a repository

Check how large all backups for a server are:

    misc/borg.sh info <backup_address>

## Getting info for a specific backup

Check how large a single backup is and how long it took to perform:

    misc/borg.sh info <backup_address>::<archive_name>

## Mounting a backup

One convenient way to access the files inside an archive is to mount it:

    mkdir mnt
    misc/borg.sh mount <backup_address>::<archive_name> mnt

You might want to mount it with `-o ignore_permissions` depending on which user
you're using to access the backup.

## Extracing files from a backup

Alternatively, if you don't want to mount it and instead want to extract files directly, you can
do so. Either extract the whole backup:

    misc/borg.sh extract <backup_address>::<archive_name>

or just a sub-directory:

    misc/borg.sh extract <backup_address>::<archive_name> backup/srv/gitlab

## Special backups

### Mariadb

For Mariadb backups are made using mariabackup to `mysql_backup_dir`.Backups can are made and
restored using the `mariabackup` tool. See also [official MariaDB docs](https://mariadb.com/kb/en/full-backup-and-restore-with-mariabackup/).

### PostgreSQL

For PostgreSQL backups are made using pg_dump to `postgres_backup_dir`.

Restoring backups can be done with `pg_restore`. See also [official PostgreSQL docs](https://www.postgresql.org/docs/current/app-pgrestore.html).

### Gitlab

GitLab is backupped up using the `gitlab_backup` tool to `gitlab_backupdir`. See also [official GitLab docs](https://docs.gitlab.com/ee/raketasks/backup_restore.html).

## Adding a new server

Adding a new server to be backed up goes as follows:

* Make sure the new servers host key is synced to `docs/ssh-known_hosts.txt` if not run:

      ansible-playbook playbooks/tasks/sync-ssh-hostkeys.yml

* Add the server to [borg-clients] in hosts

* Run the borg role on u236610.your-storagebox.de to allow the new machine to create backups

      ansible-playbook playbooks/hetzner_storagebox.yml

* Run the borg role for rsync.net to allow the new machine to create backups

      ansible-playbook playbooks/rsync.net.yml

* Run the borg role on the new machine to initialize the repository

      ansible-playbook playbooks/$machine.yml -t borg
