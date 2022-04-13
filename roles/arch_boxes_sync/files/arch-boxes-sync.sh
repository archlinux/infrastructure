#!/bin/bash
set -o nounset -o errexit -o pipefail
# https://docs.gitlab.com/ee/api/README.html#namespaced-path-encoding
readonly PROJECT_ID="archlinux%2Farch-boxes"
readonly JOB_NAME="build:secure"
readonly ARCH_BOXES_PATH="/srv/ftp/images"
readonly MAX_RELEASES="6" # 3 months

RELEASES="$(curl --silent --show-error --fail "https://gitlab.archlinux.org/api/v4/projects/${PROJECT_ID}/releases")"
LATEST_RELEASE_TAG="$(jq -r .[0].tag_name <<< "${RELEASES}")"

if [[ -d ${ARCH_BOXES_PATH}/${LATEST_RELEASE_TAG} ]]; then
  echo "Nothing to do"
  exit
fi
echo "Adding release: ${LATEST_RELEASE_TAG}"

readonly TMPDIR="$(mktemp --directory --tmpdir="/var/tmp")"
trap "rm -rf \"${TMPDIR}\"" EXIT
cd "${TMPDIR}"

readonly HTTP_CODE="$(curl --silent --show-error --fail --output "output.zip" --write-out "%{http_code}" "https://gitlab.archlinux.org/api/v4/projects/${PROJECT_ID}/jobs/artifacts/${LATEST_RELEASE_TAG}/download?job=${JOB_NAME}")"
# The releases are released/tagged and then built, so the artifacts aren't necessarily ready (yet).
if (( HTTP_CODE == 404 )); then
  echo "Skipping release: ${LATEST_RELEASE_TAG}, artifacts not ready (404)"
  exit
fi

mkdir "${LATEST_RELEASE_TAG}"
unzip output.zip
# People should download the vagrant images from Vagrant Cloud
rm output/*.box{,.*}
mv output/* "${LATEST_RELEASE_TAG}"

for FILE in "${LATEST_RELEASE_TAG}"/*; do
  if [[ $FILE == *${LATEST_RELEASE_TAG:1}* ]]; then
    FILE="${FILE##*/}"
    ln -s "${FILE}" "${LATEST_RELEASE_TAG}/${FILE//-${LATEST_RELEASE_TAG:1}}"
  fi
done

mv "${LATEST_RELEASE_TAG}" "${ARCH_BOXES_PATH}/"
ln -nsf "${LATEST_RELEASE_TAG}" "${ARCH_BOXES_PATH}/latest"

echo "Removing old releases"
cd "${ARCH_BOXES_PATH}"
comm --output-delimiter="" -3 <({ ls | grep -v latest | sort -r | head -n "${MAX_RELEASES}"; echo latest; } | sort) <(ls | sort) | tr -d '\0' | xargs --no-run-if-empty rm -rvf
