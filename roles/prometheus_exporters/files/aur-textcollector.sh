#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

TEXTFILE_COLLECTOR_DIR=${1}
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/pacman.prom

TMP_FILE=$PROM_FILE.$$
[ -e $TMP_FILE ] && rm -f $TMP_FILE

trap "rm -f $TMP_FILE" EXIT

stats="$(curl --silent --show-error --fail --max-time 10 --user-agent "aur-textcollector (https://gitlab.archlinux.org/archlinux/infrastructure)" https://aur.archlinux.org/ | hq ".stat-desc + td" text)"
packages="$(sed -n -e 1p <<< "${stats}")"
orphan_packages="$(sed -n -e 2p <<< "${stats}")"
not_updated_packages="$(sed -n -e 6p <<< "${stats}")"
# This is not 100% accurate
packages="$((packages-orphan_packages-not_updated_packages))"
users="$(sed -n -e 7p <<< "${stats}")"
trusted_users="$(sed -n -e 8p <<< "${stats}")"
users="$((users-trusted_users))"

echo "# HELP aur_packages number of packages" >> $TMP_FILE
echo "# TYPE aur_packages gauge" >> $TMP_FILE
echo "aur_packages{state=\"updated\"} $packages" >> $TMP_FILE
echo "aur_packages{state=\"orphan\"} $orphan_packages" >> $TMP_FILE
echo "aur_packages{state=\"not_updated\"} $not_updated_packages" >> $TMP_FILE

echo "# HELP aur_users number of users" >> $TMP_FILE
echo "# TYPE aur_users gauge" >> $TMP_FILE
echo "aur_users{type=\"user\"} $users" >> $TMP_FILE
echo "aur_users{type=\"tu\"} $trusted_users" >> $TMP_FILE

mv -f $TMP_FILE $PROM_FILE
