#!/usr/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

TEXTFILE_COLLECTOR_DIR=${1}
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/borg-offsite.prom


TMP_FILE=$PROM_FILE.$$
[ -e $TMP_FILE ] && rm -f $TMP_FILE

trap "rm -f $TMP_FILE" EXIT

# rsync.net borg
if [[ -f /usr/local/bin/borg-offsite ]]; then
  LAST_ARCHIVE=$(/usr/local/bin/borg-offsite list --last 1)
  LAST_ARCHIVE_NAME=$(echo $LAST_ARCHIVE | awk '{print $1}')
  LAST_ARCHIVE_DATE=$(echo $LAST_ARCHIVE | awk '{print $3" "$4}')
  LAST_ARCHIVE_TIMESTAMP=$(date -d "$LAST_ARCHIVE_DATE" +"%s")

  echo "# HELP borg_offsite_last_archive_timestamp timestamp of last backup in UTC" >> $TMP_FILE
  echo "# TYPE borg_offsite_last_archive_timestamp counter" >> $TMP_FILE
  echo "borg_offsite_last_archive_timestamp $LAST_ARCHIVE_TIMESTAMP" >> $TMP_FILE;

  REPO_SIZE=$(/usr/local/bin/borg-offsite info --json | jq '.cache.stats.unique_csize')

  echo "# HELP borg_offsite_repo_size_bytes amount of data stored in the repo in bytes" >> $TMP_FILE
  echo "# TYPE borg_offsite_repo_size_bytes gauge" >> $TMP_FILE
  echo "borg_offsite_repo_size_bytes $REPO_SIZE" >> $TMP_FILE
fi

mv -f $TMP_FILE $PROM_FILE
