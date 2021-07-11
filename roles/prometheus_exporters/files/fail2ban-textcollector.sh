#!/bin/bash

set -o errexit
set -o nounset

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

TEXTFILE_COLLECTOR_DIR=${1}
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/fail2ban.prom

TMP_FILE=$PROM_FILE.$$
[ -e $TMP_FILE ] && rm -f $TMP_FILE

trap "rm -f $TMP_FILE" EXIT

json=$(fail2ban-client banned | tr \' \")
len=$(echo $json | jq '. | length')

echo "# HELP fail2ban_bans" >> $TMP_FILE
echo "# TYPE fail2ban_bans gauge" >> $TMP_FILE

for ((i = 0; i < $len; i++ ));
do
  jail=$(echo $json | jq -r ".[${i}] | keys | .[0]")
  bans=$(echo $json | jq -r ".[${i}] | to_entries | .[0].value | length")

  echo "fail2ban_bans{jail=\"${jail}\"} $bans" >> $TMP_FILE
done

mv -f $TMP_FILE $PROM_FILE
