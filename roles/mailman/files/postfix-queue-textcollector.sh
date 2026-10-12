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
      # Queue files move between queues so use the birth time
      read -r count oldest < <(find "$dir" -type f -exec stat -c %W {} + 2>/dev/null \
        | awk -v now="$now" '{ n++; if ($1 > 0 && now - $1 > o) o = now - $1 } END { printf "%d %d\n", n, o }')
    fi

    echo "postfix_queue_messages{queue=\"${queue}\"} ${count}"
    echo "postfix_queue_oldest_message_age_seconds{queue=\"${queue}\"} ${oldest}"
  done
} > "$TMP_FILE"

mv -f "$TMP_FILE" "$PROM_FILE"
