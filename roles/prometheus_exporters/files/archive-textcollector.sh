#!/bin/bash

set -o errexit
set -o nounset

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

TEXTFILE_COLLECTOR_DIR=${1}
ARCHIVE_DIR=/srv/archive
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/archive.prom

TMP_FILE=$PROM_FILE.$$
[ -e $TMP_FILE ] && rm -f $TMP_FILE

trap "rm -f $TMP_FILE" EXIT

directory_size=$(du -sb ${ARCHIVE_DIR} | awk '{ print $1 }')
archived_packages=$(find ${ARCHIVE_DIR}/packages/ -type f -name '*.pkg.tar.xz' -o -name '*.pkg.tar.zst' | wc -l)

echo "# HELP archive_directory_size_bytes archive directory size in bytes" >> $TMP_FILE
echo "# TYPE archive_directory_size_bytes gauge" >> $TMP_FILE
echo "archive_directory_size_bytes $directory_size" >> $TMP_FILE

echo "# HELP archive_total_packages total amount of archived packages" >> $TMP_FILE
echo "# TYPE archive_total_packages gauge" >> $TMP_FILE
echo "archive_total_packages $archived_packages" >> $TMP_FILE

mv -f $TMP_FILE $PROM_FILE
