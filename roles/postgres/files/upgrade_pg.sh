#!/bin/bash
set -e

## Set the old version that we want to upgrade from.
TO_VERSION=$(pacman -Q postgresql | grep -Po '(?<=postgresql )[0-9]+\.[0-9]')

to_major=${TO_VERSION%%.*}
if (( $to_major != 14 )); then
	# NOTE: When this happens you should check the changelog and add any
	# necessary changes here. Then bump the version check.
	echo "ERROR: major upgrade detected, aborting..."
	exit 1
fi

FROM_VERSION="$(cat /var/lib/postgres/data/PG_VERSION)"
if [[ $FROM_VERSION == $TO_VERSION ]]; then
	echo "ERROR: from and to versions are equal. Have you already updated?! Aborting..."
	exit 1
fi

# free space check
used_space=$(df --local --output=pcent /var/lib/postgres/ | grep -Po '[0-9]{1,3}(?=%)')
if (( $used_space >= 50 )); then
	echo "ERROR: not enough free space for upgrade with backup, aborting..."
	exit 2
fi

if [[ -d /var/lib/postgres/data-$FROM_VERSION ]]; then
	echo "ERROR: backup data-$FROM_VERSION directory already exists, aborting..."
	exit 3
fi

pacman -S --needed "postgresql-old-upgrade>=$FROM_VERSION"

# mask postgresql.service to make sure that other services with
# Wants=postgresql.service and Restart=on-failure will not start
# it again during the upgrade
systemctl mask postgresql.service
systemctl daemon-reload
systemctl stop postgresql.service

# rename the old cluster and create a new empty 'data' directory for initdb
mv /var/lib/postgres/{data,data-$FROM_VERSION}
mkdir /var/lib/postgres/data
chown postgres: /var/lib/postgres/data
chattr -f +C /var/lib/postgres/data || :

# initialize the new cluster
su - postgres -c 'initdb --locale en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data'

# copy existing configuration and SSL certs from the old cluster
for f in pg_hba.conf postgresql.conf {fullchain,chain,privkey}.pem; do
	if [[ -e /var/lib/postgres/data-$FROM_VERSION/$f ]]; then
		cp -av /var/lib/postgres/{data-$FROM_VERSION,data}/$f
	fi
done

# running pg_upgrade from /tmp so it can create pg_upgrade_internal.log
su - postgres -c "cd /tmp && \
	pg_upgrade -b /opt/pgsql-$FROM_VERSION/bin/ -B /usr/bin/ \
	-d /var/lib/postgres/data-$FROM_VERSION -D /var/lib/postgres/data"

# unmask and start postgresql.service
systemctl unmask postgresql.service
systemctl daemon-reload
systemctl start postgresql.service

# We probably want to manually delete things for now in case this script misses
# some stuff
#su - postgres -c /var/lib/postgres/delete_old_cluster.sh
