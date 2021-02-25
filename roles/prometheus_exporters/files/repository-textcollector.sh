#!/bin/bash

set -o errexit
set -o nounset

if (( $# != 1 )); then
  echo "Missing textcollector directory argument"
  exit 1
fi

TEXTFILE_COLLECTOR_DIR=${1}
REPOS_DIR=/srv/ftp
PROM_FILE=$TEXTFILE_COLLECTOR_DIR/repository.prom

TMP_FILE=$PROM_FILE.$$
[ -e $TMP_FILE ] && rm -f $TMP_FILE

trap "rm -f $TMP_FILE" EXIT

echo "# HELP repository_directory_size_bytes repository directory size in bytes" >> $TMP_FILE
echo "# TYPE repository_directory_size_bytes gauge" >> $TMP_FILE

for dir in $REPOS_DIR/*; do
  # All Arch repositories should have an os dir, this excludes the archive and other non repo dirs.
  if [ -d "$dir/os" ]; then
    reponame=$(basename $dir)
    directory_size=$(du -Lsb ${dir} | awk '{ print $1 }')

    echo "repository_directory_size_bytes{name=\"${reponame}\"} $directory_size" >> $TMP_FILE
  fi
done

mv -f $TMP_FILE $PROM_FILE
