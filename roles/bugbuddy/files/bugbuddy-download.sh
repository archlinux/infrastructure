#!/bin/bash

set -o nounset -o errexit -o pipefail

restart_service=0
while (( $# )); do
	case $1 in
		--restart)
			restart_service=1
			shift
			;;
		*)
			echo "invalid argument: $1"
			exit 1
			;;
	esac
done

readonly NAME=bugbuddy
readonly PROJECT_ID="archlinux%2F${NAME}"
readonly TRUSTED_UIDs=(
	anthraxx@archlinux.org
)
readonly TRUSTED_KEYS=(
	E240B57E2C4630BA768E2F26FC1B547C8D8172C8
)

readonly CURRENT_RELEASE="/root/${NAME}-current_release"
readonly TARGET_DIR=/usr/local/bin

RELEASES="$(curl --silent --show-error --fail "https://gitlab.archlinux.org/api/v4/projects/${PROJECT_ID}/releases")"
LATEST_RELEASE_TAG="$(jq -r .[0].tag_name <<< "${RELEASES}")"

if [[ $LATEST_RELEASE_TAG == null ]]; then
	echo "no releases found" >&2
	exit 1
fi

if [ -f $CURRENT_RELEASE ]; then
	LATEST_RELEASE_DOWNLOAD=$(cat ${CURRENT_RELEASE})
	if [ "$LATEST_RELEASE_TAG" = "$LATEST_RELEASE_DOWNLOAD" ]; then
		echo "already at latest release"
		exit 0
	fi
fi


TMPDIR="$(mktemp --directory --tmpdir="/var/tmp" "${NAME}-download-XXXXXXXXXXXX")"
# shellcheck disable=SC2064
trap "rm -rf \"${TMPDIR}\"" EXIT
cd "${TMPDIR}"

RELEASES="$(curl --silent --show-error --fail "https://gitlab.archlinux.org/api/v4/projects/${PROJECT_ID}/releases/$LATEST_RELEASE_TAG")"
ASSETS=$(jq .assets.links <<< "${RELEASES}")
mapfile -t LINKS < <(jq -r '.[].direct_asset_url' <<< "${ASSETS}")

for link in "${LINKS[@]}"; do
	echo "downloading ${link##*/}"
	curl --progress-bar --show-error --fail --location --remote-name "${link}"
done

for uid in "${TRUSTED_UIDs[@]}"; do
	sq wkd get "${uid}"
done

for fp in "${TRUSTED_KEYS[@]}"; do
	sq --force pki link add --all "${fp}"
done

verified=0
for key in "${TRUSTED_KEYS[@]}"; do
	if sq verify --signer-cert "${key}" --detached ${NAME}.sig ${NAME}; then
		verified=1
		break
	fi
done
if (( ! verified )); then
	echo "failed to verify downloaded artifacts" >&2
	exit 1
fi

chmod +x ${NAME}
mv --verbose ${NAME} "${TARGET_DIR}/${NAME}"
echo "$LATEST_RELEASE_TAG" > $CURRENT_RELEASE

if (( restart_service )); then
	systemctl restart "${NAME}"
fi
