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
# -
#

# Download script: load-env-vars
echo "Downloading $DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT"
aws s3 cp $(echo "$DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT") $(echo "$WORKING_DIR/$CI_FOLDER$LOAD_ENV_VARS_SCRIPT")

# Download db certs: test
echo "Downloading $CERT_STORE$CERT_NAME"
aws s3 cp $(echo "$CERT_STORE$CERT_NAME") ./dbcert.crt

source $(echo "$WORKING_DIR/$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS

# Set image tage as environment variable
IMAGE_TAG="$IMAGE_REPOSITORY_NAME:$CODEBUILD_RESOLVED_SOURCE_VERSION-$CODEBUILD_BUILD_NUMBER"

echo "Build starting for container project: $CODEBUILD_BUILD_ID"
echo "Start time: $CODEBUILD_START_TIME"
echo "Started by: $CODEBUILD_INITIATOR"
echo "Build number: $CODEBUILD_BUILD_NUMBER"
echo "Git hash: $CODEBUILD_RESOLVED_SOURCE_VERSION"

# Authenticate ECR
echo "ECR: Authenticating"
echo $(aws ecr get-login-password | docker login --username AWS --password-stdin $IMAGE_REGISTRY_BASE_URL)
echo "ECR: Authenticated"

# Build docker image
echo "Build docker image"
docker build --force-rm --tag $IMAGE_TAG .
echo "Docker image successfully built: $IMAGE_TAG"

# Tag docker image - for build hash
echo 'Tagging docker image for ECR registry'
docker tag $IMAGE_TAG $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG
echo "Docker build hash image successfully tagged as: $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG"

# Push docker image - for build hash
echo 'Pushing docker image to ECR registry'
docker push $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG
echo 'Docker build hash image successfully pushed to ECR registry'

# Tag docker image - latest
echo 'Tagging docker image for ECR registry'
docker tag $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG $IMAGE_REGISTRY_BASE_URL/$IMAGE_REPOSITORY_NAME:latest
echo "Docker latest image successfully tagged as: $IMAGE_REGISTRY_BASE_URL/$IMAGE_REPOSITORY_NAME:latest"

# Push docker image - latest
echo 'Pushing docker image to ECR registry'
docker push $IMAGE_REGISTRY_BASE_URL/$IMAGE_REPOSITORY_NAME:latest
echo 'Docker latest image successfully pushed to ECR registry'

echo 'Done.'
