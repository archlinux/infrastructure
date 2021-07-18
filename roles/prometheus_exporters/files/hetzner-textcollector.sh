#!/usr/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

TEXTFILE_COLLECTOR_DIR=${1}
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/hetzner.prom


TMP_FILE=$PROM_FILE.$$
[ -e $TMP_FILE ] && rm -f $TMP_FILE

trap "rm -f $TMP_FILE" EXIT

STORAGE_BOX_DF=$(sftp -P23 u236610.your-storagebox.de <<<df 2>/dev/null | tail -1)
STORAGE_BOX_SIZE=$(( 1024 * $(awk '{print $1}' <<<$STORAGE_BOX_DF) )) # KiB -> bytes
STORAGE_BOX_USED=$(( 1024 * $(awk '{print $2}' <<<$STORAGE_BOX_DF) )) # KiB -> bytes
STORAGE_BOX_FREE=$(( 1024 * $(awk '{print $3}' <<<$STORAGE_BOX_DF) )) # KiB -> bytes

echo "# HELP hetzner_storage_box_size_bytes storage box size in bytes (excl. snapshots)" >> $TMP_FILE
echo "# TYPE hetzner_storage_box_size_bytes gauge" >> $TMP_FILE
echo "hetzner_storage_box_size_bytes $STORAGE_BOX_SIZE" >> $TMP_FILE

echo "# HELP hetzner_storage_box_used_bytes storage box used space in bytes" >> $TMP_FILE
echo "# TYPE hetzner_storage_box_used_bytes gauge" >> $TMP_FILE
echo "hetzner_storage_box_used_bytes $STORAGE_BOX_USED" >> $TMP_FILE

echo "# HELP hetzner_storage_box_free_bytes storage box free space in bytes" >> $TMP_FILE
echo "# TYPE hetzner_storage_box_free_bytes gauge" >> $TMP_FILE
echo "hetzner_storage_box_free_bytes $STORAGE_BOX_FREE" >> $TMP_FILE

mv -f $TMP_FILE $PROM_FILE
