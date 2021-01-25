#!/bin/bash

set -o errexit
set -o nounset

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

TEXTFILE_COLLECTOR_DIR=${1}
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/btrfs.prom

TMP_FILE=$PROM_FILE.$$
[ -e $TMP_FILE ] && rm -f $TMP_FILE

trap "rm -f $TMP_FILE" EXIT

list_btrfs_submounts=$(sudo btrfs filesystem show | awk '/ path /{print $NF}')

# Errors outputed by btrfs device stats /
btrfs_errors=(write_io_errs read_io_errs flush_io_errs corruption_errs generation_errs)

for btrfs_mount in ${list_btrfs_submounts[@]}; do
  for btrfs_error in "${btrfs_errors[@]}"
  do
    jq_filter=".[\"device-stats\"][].${btrfs_error}"
    errors=$(sudo btrfs --format json device stats $btrfs_mount | jq -r ${jq_filter})

    device=$(sudo btrfs --format json device stats $btrfs_mount | jq -r '.["device-stats"][].device')

    echo "# HELP btrfs_${btrfs_error} error" >> $TMP_FILE
    echo "# TYPE btrfs_${btrfs_error} gauge" >> $TMP_FILE
    echo "btrfs_${btrfs_error}{device=\"${device}\"} ${errors}" >> $TMP_FILE
  done
done

mv -f $TMP_FILE $PROM_FILE
