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

curl --silent --show-error --fail --output "output.zip" "https://gitlab.archlinux.org/api/v4/projects/${PROJECT_ID}/jobs/artifacts/${LATEST_RELEASE_TAG}/download?job=${JOB_NAME}"
mkdir "${LATEST_RELEASE_TAG}"
unzip output.zip
# People should download the vagrant images from Vagrant Cloud
rm output/*.box{,.*}
mv output/* "${LATEST_RELEASE_TAG}"

mv "${LATEST_RELEASE_TAG}" "${ARCH_BOXES_PATH}/"
ln -nsf "${LATEST_RELEASE_TAG}" "${ARCH_BOXES_PATH}/latest"

echo "Removing old releases"
cd "${ARCH_BOXES_PATH}"
comm --output-delimiter="" -3 <({ ls | grep -v latest | sort -r | head -n "${MAX_RELEASES}"; echo latest; } | sort) <(ls | sort) | xargs --no-run-if-empty rm -rvf
