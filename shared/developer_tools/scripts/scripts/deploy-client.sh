#!/bin/bash

set -euo pipefail

echo "Build starting for container project: $CODEBUILD_BUILD_ID"
echo "Start time: $CODEBUILD_START_TIME"
echo "Started by: $CODEBUILD_INITIATOR"
echo "Build number: $CODEBUILD_BUILD_NUMBER"

# Download script: load-env-vars
echo "Downloading $DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT"
aws s3 cp $(echo "$DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT") "$(pwd)/$CI_FOLDER$LOAD_ENV_VARS_SCRIPT"

source $(echo "$(pwd)/$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS $(pwd)

aws s3 sync $RELEASE_ARTEFACT_PATH "s3://$S3_HOST_BUCKET_URL"

echo '{
  "Paths": {
    "Quantity": 1,
    "Items": ["/*"]
  },
  "CallerReference": "'$CODEBUILD_START_TIME'"
}' >"$(pwd)/$CI_FOLDER/inv-batch.json"

echo $(aws cloudfront create-invalidation \
  --distribution-id $CDN_ID \
  --invalidation-batch "file://$(pwd)/$CI_FOLDER/inv-batch.json")

echo "Done."
