#!/usr/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

TEXTFILE_COLLECTOR_DIR=${1}
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/borg.prom


TMP_FILE=$PROM_FILE.$$
[ -e $TMP_FILE ] && rm -f $TMP_FILE

trap "rm -f $TMP_FILE" EXIT

# Hetzner borg
if [[ -f /usr/local/bin/borg ]]; then
  LAST_ARCHIVE=$(/usr/local/bin/borg list --last 1)
  LAST_ARCHIVE_NAME=$(echo $LAST_ARCHIVE | awk '{print $1}')
  LAST_ARCHIVE_DATE=$(echo $LAST_ARCHIVE | awk '{print $3" "$4}')
  LAST_ARCHIVE_TIMESTAMP=$(date -d "$LAST_ARCHIVE_DATE" +"%s")

  echo "# HELP borg_hetzner_last_archive_timestamp timestamp of last backup in UTC" >> $TMP_FILE
  echo "# TYPE borg_hetzner_last_archive_timestamp counter" >> $TMP_FILE
  echo "borg_hetzner_last_archive_timestamp $LAST_ARCHIVE_TIMESTAMP" >> $TMP_FILE;

  REPO_SIZE=$(/usr/local/bin/borg info --json | jq '.cache.stats.unique_csize')

  echo "# HELP borg_hetzner_repo_size_bytes amount of data stored in the repo in bytes" >> $TMP_FILE
  echo "# TYPE borg_hetzner_repo_size_bytes gauge" >> $TMP_FILE
  echo "borg_hetzner_repo_size_bytes $REPO_SIZE" >> $TMP_FILE

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
fi

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
