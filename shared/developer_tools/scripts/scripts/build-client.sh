#!/bin/bash

set -euo pipefail

echo "Build starting for client project: $CODEBUILD_BUILD_ID"
echo "Start time: $CODEBUILD_START_TIME"
echo "Started by: $CODEBUILD_INITIATOR"
echo "Build number: $CODEBUILD_BUILD_NUMBER"
echo "Git hash: $CODEBUILD_RESOLVED_SOURCE_VERSION"
echo "Branch name: $GIT_BRANCH"

# Download script: load-env-vars
echo "Downloading $DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT"
aws s3 cp $(echo "$DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT") $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT")

source $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS $(pwd)

n "22.13.1" && npm i

source $ENV_FILE && npm run build \
  -w packages/config \
  -w packages/constants \
  -w packages/utilities \
  -w packages/contracts \
  -w packages/api \
  -w packages/ui

if [[ -n "$TARGET_WORKSPACE" ]]; then
  source $ENV_FILE && npm run build -w $TARGET_WORKSPACE
fi

echo "Done."
