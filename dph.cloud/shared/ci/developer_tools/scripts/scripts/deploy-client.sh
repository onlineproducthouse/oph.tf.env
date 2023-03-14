#!/bin/bash

set -euo pipefail

#
# -----------------------------------------------------
# AWS Codebuild Default Environment Variables
# -----------------------------------------------------
#
# CODEBUILD_BUILD_ID
# CODEBUILD_START_TIME
# CODEBUILD_INITIATOR
# CODEBUILD_SOURCE_REPO_URL
# CODEBUILD_BUILD_NUMBER
#
# -----------------------------------------------------
# AWS Codebuild Job Environment Variables
# -----------------------------------------------------
#
# CI_ACTION e.g. build, deploy, migrate
# PROJECT_TYPE e.g. container, client, db
# ENVIRONMENT_NAME e.g. test, prod, ci
# WORKING_DIR e.g. .
# CI_FOLDER e.g. ./ci
# BUILD_ARTEFACT_PATH e.g. .
#
# AWS_REGION
# AWS_SSM_PARAMETER_PATHS e.g. "path1;path2;path3;..."
# CLUSTER_NAME
# DESIRED_COUNT
# CONTAINER_CPU
# CONTAINER_MEMORY_RESERVATION
#
# CERT_STORE
# CERT_NAME
# DEV_TOOLS_STORE_SCRIPTS
# LOAD_ENV_VARS_SCRIPT
# CF_INVALDIATE_SCRIPT
#
# -----------------------------------------------------
# AWS SSM Parameters - CI Environment
# -----------------------------------------------------
#
# S3_HOST_BUCKET_URL
# S3_WEBSITE_ENDPOINT
#
# -----------------------------------------------------
# AWS SSM Parameters - Runtime Environment
# -----------------------------------------------------
#
# -
#

echo "Build starting for container project: $CODEBUILD_BUILD_ID"
echo "Start time: $CODEBUILD_START_TIME"
echo "Started by: $CODEBUILD_INITIATOR"
echo "Build number: $CODEBUILD_BUILD_NUMBER"

# Download script: load-env-vars
echo "Downloading $DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT"
aws s3 cp $(echo "$DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT") $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT")

source $(echo "$(pwd)/$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS $(pwd)

source $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS $(pwd)

echo '{
  "Paths": {
    "Quantity": 1,
    "Items": ["/index.html"]
  },
  "CallerReference": "'$CODEBUILD_START_TIME'"
}' >"$(pwd)/$CI_FOLDER/inv-batch.json"

echo $(aws cloudfront create-invalidation \
  --distribution-id $CDN_ID \
  --invalidation-batch "file://$CI_FOLDER/inv-batch.json")

echo "Done."
