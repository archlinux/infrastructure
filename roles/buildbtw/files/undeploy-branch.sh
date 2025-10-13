#!/bin/bash

set -Eeuo pipefail

# Undeploy a branch
# ./undeploy-branch.sh <branch>

branch=$1

systemctl disable --now "buildbtw@${branch}"
echo "Undeploying ${branch}"
