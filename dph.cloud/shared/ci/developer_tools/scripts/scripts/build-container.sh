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
# IMAGE_REGISTRY_BASE_URL
# IMAGE_REPOSITORY_NAME
#
# -----------------------------------------------------
# AWS SSM Parameters - CI Environment
# -----------------------------------------------------
#
# -
#
# -----------------------------------------------------
# AWS SSM Parameters - Runtime Environment
# -----------------------------------------------------
#
# -
#

export BUILDX_VERSION=$(curl --silent "https://api.github.com/repos/docker/buildx/releases/latest" | jq -r .tag_name)
curl -JLO "https://github.com/docker/buildx/releases/download/$BUILDX_VERSION/buildx-$BUILDX_VERSION.linux-amd64"
mkdir -p ~/.docker/cli-plugins
mv "buildx-$BUILDX_VERSION.linux-amd64" ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx
docker run --privileged --rm tonistiigi/binfmt --install arm64

echo "Changing to working directory: $WORKING_DIR"
cd $(echo $WORKING_DIR)

# Download script: load-env-vars
echo "Downloading $DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT"
aws s3 cp $(echo "$DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT") $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT")

# Download db certs: test
echo "Downloading $CERT_STORE$CERT_NAME"
aws s3 cp $(echo "$CERT_STORE$CERT_NAME") ./dbcert.crt

source $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS $(pwd)

echo "Build starting for container project: $CODEBUILD_BUILD_ID"
echo "Start time: $CODEBUILD_START_TIME"
echo "Started by: $CODEBUILD_INITIATOR"
echo "Build number: $CODEBUILD_BUILD_NUMBER"

# Set image tage as environment variable
IMAGE_TAG="$IMAGE_REPOSITORY_NAME:latest"

# Authenticate ECR
echo "ECR: Authenticating"
echo $(aws ecr get-login-password | docker login --username AWS --password-stdin $IMAGE_REGISTRY_BASE_URL)
echo "ECR: Authenticated"

# Build docker image
echo "Build docker image"
docker buildx create --use --name multiarch
docker buildx build --push --platform=linux/arm64,linux/amd64 --force-rm --tag $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG .
echo "Docker image successfully built: $IMAGE_TAG"

# # Tag docker image
# echo 'Tagging docker image for ECR registry'
# docker tag $IMAGE_TAG $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG
# echo "Docker build hash image successfully tagged as: $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG"

# # Push docker image
# echo 'Pushing docker image to ECR registry'
# docker push $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG
# echo 'Docker build hash image successfully pushed to ECR registry'

echo 'Done.'
