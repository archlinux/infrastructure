#!/bin/bash

set -Eeuo pipefail

# Deploy a branch
# ./deploy-branch.sh <branch>

branch=$1

# Restart so that a potentially newer image may get pulled
systemctl restart "buildbtw@${branch}"
systemctl enable "buildbtw@${branch}"
echo "Deploying ${branch}"
