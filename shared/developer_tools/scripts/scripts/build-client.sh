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

cp $ENV_FILE $(pwd)/packages/ui
cp $ENV_FILE $(pwd)/apps/www
cp $ENV_FILE $(pwd)/apps/portal
cp $ENV_FILE $(pwd)/apps/registration
cp $ENV_FILE $(pwd)/apps/console

n "22.13.1" && npm i

source $ENV_FILE && npm run build

echo "Done."
