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
# IMAGE_REGISTRY_BASE_URL
# IMAGE_REPOSITORY_NAME
#
# TASK_FAMILY
# TASK_ROLE_ARN
#
# CONTAINER_NAME
# CONTAINER_CPU
# CONTAINER_MEMORY_RESERVATION
# CONTAINER_PORT
#
# PAPERTRAIL_URL
#
# SERVICE_NAME
# TARGET_GROUP_ARN
#
# -----------------------------------------------------
# AWS SSM Parameters - Runtime Environment
# -----------------------------------------------------
#
# PROJECT_NAME
#
# DB_PROTOCOL
# DB_USERNAME
# DB_PASSWORD
# DB_HOST
# DB_PORT
# DB_NAME
#
# EMAIL_BUSINESS_ADDRESS
# EMAIL_OWNERSHIP
#
# NO_REPLY_EMAIL_ADDRESS
#
# REDIS_CONNECTION_STRING
# REDIS_HOST
#
# AWS_REGION
#
# API_KEYS
# API_PORT
#
# SENDGRID_SENDER_ADDRESS
# SENDGRID_SENDER_CITY
# SENDGRID_SENDER_STATE
# SENDGRID_SENDER_ZIP
# SENDGRID_SENDER_NEW_ACCOUNT_TEMPL_ID
# SENDGRID_SENDER_RECOVER_ACCOUNT_TEMPL_ID
# SENDGRID_SENDER_NEW_EMAIL_ADDR_TEMPL_ID
# SENDGRID_SENDER_PANIC_ALERT_ACL_LINK_CLOSE_PERSON
# SENDGRID_SENDER_PANIC_ALERT_ACL_LINK_SERVICE_PROVIDER
# SENDGRID_SENDER_PANIC_ALERT_ACL_LINK_ADMIN
# SENDGRID_SENDER_PANIC_ALERT_ACL_OTP
# SENDGRID_SENDER_CLOSE_PERSON_INVITE_TEMPL_ID
# SENDGRID_SENDER_CLOSE_PERSON_CONFIRMATION_TEMPL_ID
# SENDGRID_SENDER_EMAIL_ADDRESS
# SENDGRID_API_KEY
#
# SMS_API_SENDER_PHONE_NUMBER
# SMS_API_ACCOUNT_SID
# SMS_API_AUTH_TOKEN
#
# CLOUDINARY_CLOUD_NAME
# CLOUDINARY_API_KEY
# CLOUDINARY_API_SECRET
# CLOUDINARY_FOLDER
#
# OTP_LENGTH
# OTP_TIME_TO_LIVE_IN_MINUTES
#
# RUN_SWAGGER
#
# ADMIN_APP_URL
# WEB_APP_URL
# PANIC_ALERT_APP_URL
#
# GOOGLE_GEOCODING_API_KEY
#
# PAPERTRAIL_URL
#

echo "Changing to working directory: $WORKING_DIR"
cd $(echo $WORKING_DIR)

ECS_FOLDER="./$(echo $CI_FOLDER)/ecs"
ECS_TASK_DEFINITION_TEMPLATE="$ECS_FOLDER/task.json"
ECS_TASK="$ECS_FOLDER/task-ecs.json"
SERVICE_FILE="$ECS_FOLDER/service.json"

# Download script: load-env-vars
# Download script: load-env-vars
echo "Downloading $DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT"
aws s3 cp $(echo "$DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT") $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT")

source $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS $(pwd)

echo "Deploying to environment: $ENVIRONMENT_NAME"
echo "Deploying ECS container for: $CODEBUILD_BUILD_ID"
echo "Start time: $CODEBUILD_START_TIME"
echo "Started by: $CODEBUILD_INITIATOR"
echo "Build number: $CODEBUILD_BUILD_NUMBER"

# Set image tage as environment variable
IMAGE_TAG="$IMAGE_REPOSITORY_NAME:latest"

MAXIMUM_HEALTHY_PERCENT=100
MINIMUM_HEALTHY_PERCENTAGE=0

if [[ ${ENVIRONMENT_NAME} == "production" ]]; then
  MAXIMUM_HEALTHY_PERCENT=200
  MINIMUM_HEALTHY_PERCENTAGE=100
fi

echo "Minimum healthy percent: ${MINIMUM_HEALTHY_PERCENTAGE}"
echo "Maximum healthy percent: ${MAXIMUM_HEALTHY_PERCENT}"

# populate ecs json files
echo '{
  "family": "'${TASK_FAMILY}'",
  "taskRoleArn": "'${TASK_ROLE_ARN}'",
  "executionRoleArn": "'${TASK_ROLE_ARN}'",
  "networkMode": "bridge",
  "requiresCompatibilities": [
    "EC2"
  ],
  "containerDefinitions": [
    {
      "name": "'${CONTAINER_NAME}'",
      "essential": true,
      "image": '"$IMAGE_REGISTRY_BASE_URL/$IMAGE_TAG"',
      "cpu": '${CONTAINER_CPU}',
      "memoryReservation": '${CONTAINER_MEMORY_RESERVATION}',
      "portMappings": [
        {
          "protocol": "tcp",
          "containerPort": '${CONTAINER_PORT}',
          "hostPort": '${CONTAINER_PORT}'
        }
      ],
      "logConfiguration": {
        "logDriver": "syslog",
        "options": {
          "syslog-address": "'${LOG_URL}'"
        }
      },
      "environmentFiles": [
        {
          "value": "arn:aws:s3:::'${ENV_FILE_STORE_LOCATION}'/'${ENV_FILE_NAME}'",
          "type": "s3"
        }
      ]
    }
  ]
}' >${ECS_TASK_DEFINITION_TEMPLATE}

echo "Task definition template successfully created"

echo $(cat ${ECS_TASK_DEFINITION_TEMPLATE}) >${ECS_TASK}

# Register Task Definition
echo "Registering ECS task definition"
aws ecs register-task-definition --family ${TASK_FAMILY} --cli-input-json file://${ECS_TASK}

CURRENT_ECS_SERVICE_NAME=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | jq '.services[0].serviceName')

echo "aws ecs describe-services output: ${CURRENT_ECS_SERVICE_NAME}"

if [[ ${CURRENT_ECS_SERVICE_NAME} == "\"${SERVICE_NAME}\"" ]]; then
  echo "Updating ECS service: $SERVICE_NAME"

  echo "Getting task revision"
  TASK_REVISION=$(aws ecs describe-task-definition --task-definition ${TASK_FAMILY} | jq '.taskDefinition.revision')
  echo "Task revision: ${TASK_REVISION}"

  echo '{
    "taskDefinition": "'${TASK_FAMILY}'",
    "desiredCount": '${DESIRED_COUNT}',
    "deploymentConfiguration": {
      "maximumPercent": '${MAXIMUM_HEALTHY_PERCENT}',
      "minimumHealthyPercent": '${MINIMUM_HEALTHY_PERCENTAGE}'
    }
  }' >${SERVICE_FILE}

  aws ecs update-service --cluster ${CLUSTER_NAME} \
    --service ${SERVICE_NAME} \
    --task-definition ${TASK_FAMILY}:${TASK_REVISION} \
    --desired-count ${DESIRED_COUNT} \
    --cli-input-json file://${SERVICE_FILE}
else
  echo "Creating ECS service: $SERVICE_NAME"

  echo '{
    "serviceName": "'${SERVICE_NAME}'",
    "taskDefinition": "'${TASK_FAMILY}'",
    "loadBalancers": [
      {
        "targetGroupArn": "'${TARGET_GROUP_ARN}'",
        "containerName": "'${CONTAINER_NAME}'",
        "containerPort": '${CONTAINER_PORT}'
      }
    ],
    "desiredCount": '${DESIRED_COUNT}',
    "launchType": "EC2",
    "deploymentConfiguration": {
      "maximumPercent": '${MAXIMUM_HEALTHY_PERCENT}',
      "minimumHealthyPercent": '${MINIMUM_HEALTHY_PERCENTAGE}'
    }
  }' >${SERVICE_FILE}

  aws ecs create-service --cluster ${CLUSTER_NAME} \
    --service-name ${SERVICE_NAME} \
    --cli-input-json file://${SERVICE_FILE}
fi

echo "Done."
