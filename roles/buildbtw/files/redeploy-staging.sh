#!/bin/bash

set -Eeuo pipefail

# Deploy a buildbtw container for development or staging
# ./deploy.sh <tag>

tag=$1

podman
