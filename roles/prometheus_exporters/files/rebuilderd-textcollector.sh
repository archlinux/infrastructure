#!/bin/bash

set -o errexit
set -o nounset

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

HOSTNAME=$(hostname)
TEXTFILE_COLLECTOR_DIR=${1}
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/rebuilderd.prom

TMP_FILE=$PROM_FILE.$$
[ -e $TMP_FILE ] && rm -f $TMP_FILE

trap "rm -f $TMP_FILE" EXIT

queuelength=$(rebuildctl queue ls --json | jq '.queue | length')
workers=$(rebuildctl status | wc -l)

echo "# HELP rebuilderd_queue_length number of packages in rebuilderd queue" >> $TMP_FILE
echo "# TYPE rebuilderd_queue_length gauge" >> $TMP_FILE
echo "rebuilderd_queue_length{host=\"${HOSTNAME}\"} $queuelength" >> $TMP_FILE

echo "# HELP rebuilderd_workers number of rebuilderd-workers available" >> $TMP_FILE
echo "# TYPE rebuilderd_workers gauge" >> $TMP_FILE
echo "rebuilderd_workers{host=\"${HOSTNAME}\"} $workers" >> $TMP_FILE

mv -f $TMP_FILE $PROM_FILE
