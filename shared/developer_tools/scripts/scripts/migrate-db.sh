#!/bin/bash

set -euo pipefail

if [[ $IS_RUNNING == "false" ]]; then
  echo "Target environment is not running"
  exit 0
fi

if [[ $ENABLE_DEPLOYMENT != "true" ]]; then
  echo "Target environment is not enabled for deployments"
  exit 0
fi

echo "Changing to working directory: $WORKING_DIR"
cd $(echo $WORKING_DIR)

# Download script: load-env-vars
echo "Downloading $DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT"
aws s3 cp $(echo "$DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT") $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT")

source $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS $(pwd)

echo "Database migration starting for container image: $CODEBUILD_BUILD_ID"
echo "Start time: $CODEBUILD_START_TIME"
echo "Started by: $CODEBUILD_INITIATOR"
echo "Build number: $CODEBUILD_BUILD_NUMBER"

# Authenticate ECR
echo "ECR: Authenticating"
echo $(aws ecr get-login-password | docker login --username AWS --password-stdin $IMAGE_REGISTRY_BASE_URL)
echo "ECR: Authenticated"

source $RELEASE_MANIFEST && docker pull $DKR_IMAGE
source $RELEASE_MANIFEST && docker run --env-file .env $DKR_IMAGE

echo "Done."
