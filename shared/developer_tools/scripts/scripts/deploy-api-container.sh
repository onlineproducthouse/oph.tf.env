#!/bin/bash

set -euo pipefail

if [[ $IS_RUNNING != "true" ]]; then
  echo "Target environment is not running"
  exit 0
fi

if [[ $ENABLE_DEPLOYMENT != "true" ]]; then
  echo "Target environment is not enabled for deployments"
  exit 0
fi

echo "Changing to working directory: $WORKING_DIR"
cd $(echo $WORKING_DIR)

ECS_FOLDER="$(echo $CI_FOLDER)/ecs"
ECS_TASK_DEFINITION_TEMPLATE="$ECS_FOLDER/task.json"
ECS_TASK="$ECS_FOLDER/task-ecs.json"
SERVICE_FILE="$ECS_FOLDER/service.json"

# mkdir $CI_FOLDER
mkdir $ECS_FOLDER

touch $ECS_TASK_DEFINITION_TEMPLATE
touch $ECS_TASK
touch $SERVICE_FILE

# Download script: load-env-vars
echo "Downloading $DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT"
aws s3 cp $(echo "$DEV_TOOLS_STORE_SCRIPTS$LOAD_ENV_VARS_SCRIPT") $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT")

source $(echo "$CI_FOLDER$LOAD_ENV_VARS_SCRIPT") $AWS_REGION $AWS_SSM_PARAMETER_PATHS $(pwd)

echo "Deploying to environment: $ENVIRONMENT_NAME"
echo "Deploying ECS container for: $CODEBUILD_BUILD_ID"
echo "Start time: $CODEBUILD_START_TIME"
echo "Started by: $CODEBUILD_INITIATOR"
echo "Build number: $CODEBUILD_BUILD_NUMBER"

LOCAL_ENV_FILE_NAME="${ENV_FILE_STORE_LOCATION}/${ENV_FILE_NAME}"

# populate ecs json files
source $RELEASE_MANIFEST && echo '{
  "family": "'${TASK_FAMILY}'",
  "taskRoleArn": "'${TASK_ROLE_ARN}'",
  "executionRoleArn": "'${TASK_ROLE_ARN}'",
  "networkMode": "'${NETWORK_MODE}'",
  "requiresCompatibilities": [
    "EC2"
  ],
  "cpu": "'${CONTAINER_CPU}'",
  "memory": "'${CONTAINER_MEMORY_RESERVATION}'",
  "containerDefinitions": [
    {
      "name": "'${CONTAINER_NAME}'",
      "essential": true,
      "image": "'$DKR_IMAGE'",
      "cpu": '${CONTAINER_CPU}',
      "memory": '${CONTAINER_MEMORY_RESERVATION}',
      "portMappings": [
        {
          "name": "'${PORT_MAPPING_NAME}'",
          "protocol": "tcp",
          "containerPort": '${CONTAINER_PORT}',
          "hostPort": '${CONTAINER_PORT}'
        }
      ],
      "logConfiguration": {
        "logDriver": "'${LOG_DRIVER}'",
        "options": {
          "awslogs-group": "'${LOG_GROUP}'",
          "awslogs-region": "'${AWS_REGION}'",
          "awslogs-stream-prefix": "'${LOG_PREFIX}'"
        }
      },
      "environmentFiles": [
        {
          "value": "arn:aws:s3:::'${LOCAL_ENV_FILE_NAME}'",
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

echo "Updating ECS service: $SERVICE_NAME"

echo "Getting task revision"
TASK_REVISION=$(aws ecs describe-task-definition --task-definition ${TASK_FAMILY} | jq '.taskDefinition.revision')
echo "Task revision: ${TASK_REVISION}"

aws ecs update-service --force-new-deployment \
  --cluster ${CLUSTER_NAME} \
  --service ${SERVICE_NAME} \
  --task-definition ${TASK_FAMILY}:${TASK_REVISION}

echo "Done."
