#!/bin/bash

set -Eeuo pipefail

# Re-deploy buildbtw staging
# ./redeploy-staging.sh

systemctl restart buildbtw
echo "Re-deploying staging"
