#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

TEXTFILE_COLLECTOR_DIR=${1}
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/postfix_queue.prom
TMP_FILE=$PROM_FILE.$$

trap "rm -f $TMP_FILE" EXIT

SPOOL=/var/spool/postfix
now=$(date +%s)

{
  echo "# HELP postfix_queue_messages Number of messages in a postfix mail queue"
  echo "# TYPE postfix_queue_messages gauge"
  echo "# HELP postfix_queue_oldest_message_age_seconds Age in seconds of the oldest message in a postfix mail queue"
  echo "# TYPE postfix_queue_oldest_message_age_seconds gauge"

  for queue in active deferred incoming hold; do
    dir="$SPOOL/$queue"
    count=0
    oldest=0

    if [ -d "$dir" ]; then
      while IFS= read -r -d '' f; do
        count=$((count + 1))
        mtime=$(stat -c %Y "$f")
        age=$((now - mtime))
        (( age > oldest )) && oldest=$age
      done < <(find "$dir" -type f -print0)
    fi

    echo "postfix_queue_messages{queue=\"${queue}\"} ${count}"
    echo "postfix_queue_oldest_message_age_seconds{queue=\"${queue}\"} ${oldest}"
  done
} > "$TMP_FILE"

mv -f "$TMP_FILE" "$PROM_FILE"
