#!/bin/bash

set -euox pipefail

#
# -----------------------------------------------------
# Script parameters
# -----------------------------------------------------
#
# $1 = $ROLE_ARN
# $2 = $ROLE_SESSION_NAME
#

# Usage: bash assume-role.sh <ROLE_ARN> <ROLE_SESSION_NAME>

ROLE_ARN=$1
ROLE_SESSION_NAME=$2

ASSUME_ROLE_RESPONSE=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name $ROLE_SESSION_NAME)
export AWS_ACCESS_KEY_ID=$(echo $ASSUME_ROLE_RESPONSE | jq -r '.Credentials''.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $ASSUME_ROLE_RESPONSE | jq -r '.Credentials''.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $ASSUME_ROLE_RESPONSE | jq -r '.Credentials''.SessionToken')
