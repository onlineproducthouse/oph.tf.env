#!/bin/bash

set -euox pipefail

#
# -----------------------------------------------------
# Script parameters
# -----------------------------------------------------
#
# $1 = $AWS_REGION
# $2 = $SOURCE_IMAGE_TAG, e.g. node:20, some-repo/image:tag
# $3 = $TARGET_IMAGE_TAG
#

AWS_REGION=$1
SOURCE_IMAGE_TAG=$2
TARGET_IMAGE_TAG=$3

ECR=$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$AWS_REGION.amazonaws.com

aws ecr get-login-password --region=$AWS_REGION |
  docker login --username AWS --password-stdin $ECR

docker pull $SOURCE_IMAGE_TAG
docker tag $SOURCE_IMAGE_TAG $TARGET_IMAGE_TAG
docker push $TARGET_IMAGE_TAG
