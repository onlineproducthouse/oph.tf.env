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
# CODEBUILD_RESOLVED_SOURCE_VERSION # git hash
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
# IMAGE_REGISTRY_BASE_URL
# IMAGE_REPOSITORY_NAME
#
# -----------------------------------------------------
# AWS SSM Parameters - Runtime Environment
# -----------------------------------------------------
#
# DB_PROTOCOL
# DB_USERNAME
# DB_PASSWORD
# DB_HOST
# DB_PORT
# DB_NAME
#

# Download script: load-env-vars
echo "Downloading $DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT"
aws s3 cp $(echo "$DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT") $(echo "$WORKING_DIR/$CI_FOLDER$LOAD_ENV_VARS_SCRIPT")

source $(echo "$WORKING_DIR/$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS

echo "Build starting for container project: $CODEBUILD_BUILD_ID"
echo "Start time: $CODEBUILD_START_TIME"
echo "Started by: $CODEBUILD_INITIATOR"
echo "Build number: $CODEBUILD_BUILD_NUMBER"
echo "Git hash: $CODEBUILD_RESOLVED_SOURCE_VERSION"

# Authenticate ECR
echo "ECR: Authenticating"
echo $(aws ecr get-login-password | docker login --username AWS --password-stdin $IMAGE_REGISTRY_BASE_URL)
echo "ECR: Authenticated"

# Set image tage as environment variable
IMAGE_TAG="$IMAGE_REPOSITORY_NAME:$CODEBUILD_RESOLVED_SOURCE_VERSION-$CODEBUILD_BUILD_NUMBER"

# docker pull $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG

docker run $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG \
  -e DB_PROTOCOL \
  -e DB_USERNAME \
  -e DB_PASSWORD \
  -e DB_HOST \
  -e DB_PORT \
  -e DB_NAME \
  -e ENVIRONMENT_NAME

echo "Done."
