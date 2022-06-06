#!/bin/bash

set -o nounset -o errexit -o pipefail

NAME=gluebuddy
LATEST_GLUEBUDDY_FILE=/root/latest_release
readonly PROJECT_ID="archlinux%2Fgluebuddy"

RELEASES="$(curl --silent --show-error --fail "https://gitlab.archlinux.org/api/v4/projects/${PROJECT_ID}/releases")"
LATEST_RELEASE_TAG="$(jq -r .[0].tag_name <<< "${RELEASES}")"

if [ -f $LATEST_GLUEBUDDY_FILE ]; then
   LATEST_RELEASE_DOWNLOAD=$(cat ${LATEST_GLUEBUDDY_FILE})
  if [ "$LATEST_RELEASE_TAG" = "$LATEST_RELEASE_DOWNLOAD" ]; then
    exit 0
  fi
fi


readonly TMPDIR="$(mktemp --directory --tmpdir="/var/tmp")"
trap "rm -rf \"${TMPDIR}\"" EXIT
cd "${TMPDIR}"

RELEASES="$(curl --silent --show-error --fail "https://gitlab.archlinux.org/api/v4/projects/${PROJECT_ID}/releases/$LATEST_RELEASE_TAG")"
ASSETS=$(echo $RELEASES | jq .assets.links)
LINKS=$(echo $ASSETS | jq -r '.[].direct_asset_url')
links=($LINKS)

for i in "${links[@]}"
do
  curl -O $i
done

sq verify --signer-cert <(sq wkd get anthraxx@archlinux.org) --detached ${NAME}.sig ${NAME} || \
	sq verify --signer-cert <(sq wkd get jelle@archlinux.org) --detached ${NAME}.sig ${NAME}

mv ${NAME} /usr/local/bin/${NAME}
chmod +x /usr/local/bin/${NAME}
echo $LATEST_RELEASE_TAG > $LATEST_GLUEBUDDY_FILE
