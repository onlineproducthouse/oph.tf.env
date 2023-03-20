#!/bin/bash

set -euo pipefail

export BUILDX_VERSION=$(curl --silent "https://api.github.com/repos/docker/buildx/releases/latest" | jq -r .tag_name)
curl -JLO "https://github.com/docker/buildx/releases/download/$BUILDX_VERSION/buildx-$BUILDX_VERSION.linux-amd64"
mkdir -p ~/.docker/cli-plugins
mv "buildx-$BUILDX_VERSION.linux-amd64" ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx

echo "Changing to working directory: $WORKING_DIR"
cd $(echo $WORKING_DIR)

# Download script: load-env-vars
echo "Downloading $DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT"
aws s3 cp $(echo "$DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT") $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT")

# Download db certs: test
echo "Downloading $CERT_STORE$CERT_NAME"
aws s3 cp $(echo "$CERT_STORE$CERT_NAME") ./dbcert.crt

source $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS $(pwd)

docker run --privileged --rm "$IMAGE_REGISTRY_BASE_URL/tonistiigi/binfmt:latest" --install arm64

echo "Build starting for container project: $CODEBUILD_BUILD_ID"
echo "Start time: $CODEBUILD_START_TIME"
echo "Started by: $CODEBUILD_INITIATOR"
echo "Build number: $CODEBUILD_BUILD_NUMBER"
echo "Git hash: $CODEBUILD_RESOLVED_SOURCE_VERSION"
echo "Branch name: $GIT_BRANCH"

# Set image tage as environment variable
IMAGE_TAG="$IMAGE_REPOSITORY_NAME:latest"
if [[ "$GIT_BRANCH" != "dev" ]]; then
  IMAGE_TAG="$IMAGE_REPOSITORY_NAME:$CODEBUILD_RESOLVED_SOURCE_VERSION"
fi

# Authenticate ECR
echo "ECR: Authenticating"
echo $(aws ecr get-login-password | docker login --username AWS --password-stdin $IMAGE_REGISTRY_BASE_URL)
echo "ECR: Authenticated"

# Build docker image
echo "Build docker image"
docker buildx create --use --name multiarch
docker buildx build --push \
  --force-rm \
  --platform=linux/arm64,linux/amd64 \
  --tag $IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG \
  --build-arg IMAGE_REGISTRY_BASE_URL=$IMAGE_REGISTRY_BASE_URL \
  .

echo "Docker image successfully built: $IMAGE_TAG"

echo 'Done.'
