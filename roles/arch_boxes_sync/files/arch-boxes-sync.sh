#!/bin/bash
set -o nounset -o errexit -o pipefail
# https://docs.gitlab.com/ee/api/README.html#namespaced-path-encoding
readonly PROJECT_ID="archlinux%2Farch-boxes"
readonly ARCH_BOXES_PATH="/srv/ftp/images"
readonly MAX_RELEASES="6" # 3 months

PACKAGES="$(curl --silent --show-error --fail "https://gitlab.archlinux.org/api/v4/projects/${PROJECT_ID}/packages?per_page=1&sort=desc")"
LATEST_VERSION="$(jq -r .[0].version <<< "${PACKAGES}")"

if [[ -d ${ARCH_BOXES_PATH}/${LATEST_VERSION} ]]; then
  echo "Nothing to do"
  exit
fi

# The files aren't uploaded atomic, so avoid missing files by requiring every package to be at least 5 minutes old.
if (( $(date -d "-5 min" +%s) < $(date -d "$(jq -r .[0].created_at <<< "${PACKAGES}")" +%s) )); then
  echo "Skipping release: ${LATEST_VERSION}, too new"
  exit
fi

echo "Adding release: ${LATEST_VERSION}"

PACKAGE_ID="$(jq -r .[0].id <<< "${PACKAGES}")"
PACKAGE_NAME="$(jq -r .[0].name <<< "${PACKAGES}")"
PACKAGE_FILES="$(curl --silent --show-error --fail "https://gitlab.archlinux.org/api/v4/projects/${PROJECT_ID}/packages/${PACKAGE_ID}/package_files")"

readonly TMPDIR="$(mktemp --directory --tmpdir="/var/tmp")"
trap "rm -rf \"${TMPDIR}\"" EXIT
cd "${TMPDIR}"

mkdir "${LATEST_VERSION}"
while IFS= read -r FILE; do
  FILE_CREATED_AT="$(jq -r .created_at <<< "${FILE}")"
  FILE_NAME="$(jq -r .file_name <<< "${FILE}")"
  FILE_SHA256="$(jq -r .file_sha256 <<< "${FILE}")"

  # People should download the vagrant images from Vagrant Cloud
  if [[ $FILE_NAME =~ .*\.box(|\..*)$ ]]; then
    continue
  fi

  curl --silent --show-error --fail --output "${LATEST_VERSION}/${FILE_NAME}" "https://gitlab.archlinux.org/api/v4/projects/${PROJECT_ID}/packages/generic/${PACKAGE_NAME}/${LATEST_VERSION}/${FILE_NAME}"
  sha256sum --quiet -c <<< "${FILE_SHA256} ${LATEST_VERSION}/${FILE_NAME}"
  touch --no-create --date="@$(date -d "${FILE_CREATED_AT}" +%s)" "${LATEST_VERSION}/${FILE_NAME}"
done < <(jq -c .[] <<< "${PACKAGE_FILES}")

for FILE in "${LATEST_VERSION}"/*; do
  if [[ $FILE == *${LATEST_VERSION:1}* ]]; then
    DEST="${FILE//-${LATEST_VERSION:1}}"
    if [[ $FILE =~ .*\.SHA256$ ]]; then
      sed "s/-${LATEST_VERSION:1}//" "${FILE}" > "${DEST}"
      touch --no-create --reference="${FILE}" "${DEST}"
    # Don't create a symlink for the .SHA256.sig file, as we break the signature by fixing the checksum file.
    elif [[ $FILE =~ .*\.SHA256.sig$ ]]; then
      continue
    else
      SYMLINK="${FILE##*/}"
      ln -s "${SYMLINK}" "${DEST}"
      touch --no-create --reference="${FILE}" --no-dereference "${DEST}"
    fi
  fi
done

mv "${LATEST_VERSION}" "${ARCH_BOXES_PATH}/"
ln -nsf "${LATEST_VERSION}" "${ARCH_BOXES_PATH}/latest"

echo "Removing old releases"
cd "${ARCH_BOXES_PATH}"
comm --output-delimiter="" -3 <({ ls | grep -v latest | sort -r | head -n "${MAX_RELEASES}"; echo latest; } | sort) <(ls | sort) | tr -d '\0' | xargs --no-run-if-empty rm -rvf
