#!/bin/bash

set -euo pipefail

# Parameters

EMPTY_PARAMETER="-1"

DESIRED_STATE=${1:=$EMPTY_PARAMETER}
PRODUCT_SHORT_NAME=${2:=$EMPTY_PARAMETER}

if [[ "$DESIRED_STATE" == "$EMPTY_PARAMETER" ]]; then
  echo "missing required parameter: DESIRED_STATE"
  echo "parameter DESIRED_STATE must either be:"
  echo " - up, OR"
  echo " - down"
  exit 0
fi

if [[ "$PRODUCT_SHORT_NAME" == "$EMPTY_PARAMETER" ]]; then
  echo "missing required parameter: PRODUCT_SHORT_NAME"
  exit 0
fi

# prepare

DPH_PRODUCT_SHORT_NAME=$PRODUCT_SHORT_NAME

DPH_PRODUCT_PLATFROM_CONFIG_PATH="./global/config"
DPH_PRODUCT_SERVICE_FOLDER="$(pwd)/service"

DPH_PRODUCT_API_NAME="$DPH_PRODUCT_SHORT_NAME-api"
DPH_PRODUCT_DATABASE_NAME="$DPH_PRODUCT_SHORT_NAME-database"
DPH_PRODUCT_WEB_STORYBOOK_NAME="$DPH_PRODUCT_SHORT_NAME-web-storybook"
DPH_PRODUCT_WEB_WWW_NAME="$DPH_PRODUCT_SHORT_NAME-web-www"
DPH_PRODUCT_WEB_PORTAL_NAME="$DPH_PRODUCT_SHORT_NAME-web-portal"
DPH_PRODUCT_WEB_CONSOLE_NAME="$DPH_PRODUCT_SHORT_NAME-web-console"

DPH_PRODUCT_API_TEST_PATH="$DPH_PRODUCT_SERVICE_FOLDER/$DPH_PRODUCT_API_NAME/test"

DPH_PRODUCT_API_CI_PATH="$DPH_PRODUCT_SERVICE_FOLDER/$DPH_PRODUCT_API_NAME/ci"
DPH_PRODUCT_DATABASE_CI_PATH="$DPH_PRODUCT_SERVICE_FOLDER/$DPH_PRODUCT_DATABASE_NAME/ci"
DPH_PRODUCT_WEB_STORYBOOK_CI_PATH="$DPH_PRODUCT_SERVICE_FOLDER/$DPH_PRODUCT_WEB_STORYBOOK_NAME/ci"
DPH_PRODUCT_WEB_WWW_CI_PATH="$DPH_PRODUCT_SERVICE_FOLDER/$DPH_PRODUCT_WEB_WWW_NAME/ci"
DPH_PRODUCT_WEB_PORTAL_CI_PATH="$DPH_PRODUCT_SERVICE_FOLDER/$DPH_PRODUCT_WEB_PORTAL_NAME/ci"
DPH_PRODUCT_WEB_CONSOLE_CI_PATH="$DPH_PRODUCT_SERVICE_FOLDER/$DPH_PRODUCT_WEB_CONSOLE_NAME/ci"

DPH_VPC_IN_USE=false
DPH_VPC_CIDR_BLOCK="10.0.0.0/16"
if [[ "$DESIRED_STATE" == "up" ]]; then
  DPH_VPC_IN_USE=true
fi

# apply

terraform -chdir=$DPH_PRODUCT_API_TEST_PATH init
terraform -chdir=$DPH_PRODUCT_API_TEST_PATH apply --auto-approve -var vpc_cidr_block=$DPH_VPC_CIDR_BLOCK -var vpc_in_use=$DPH_VPC_IN_USE

terraform -chdir=$DPH_PRODUCT_PLATFROM_CONFIG_PATH init
terraform -chdir=$DPH_PRODUCT_PLATFROM_CONFIG_PATH apply --auto-approve

terraform -chdir=$DPH_PRODUCT_API_CI_PATH init
terraform -chdir=$DPH_PRODUCT_API_CI_PATH apply --auto-approve

terraform -chdir=$DPH_PRODUCT_DATABASE_CI_PATH init
terraform -chdir=$DPH_PRODUCT_DATABASE_CI_PATH apply --auto-approve

terraform -chdir=$DPH_PRODUCT_WEB_STORYBOOK_CI_PATH init
terraform -chdir=$DPH_PRODUCT_WEB_STORYBOOK_CI_PATH apply --auto-approve

terraform -chdir=$DPH_PRODUCT_WEB_WWW_CI_PATH init
terraform -chdir=$DPH_PRODUCT_WEB_WWW_CI_PATH apply --auto-approve

terraform -chdir=$DPH_PRODUCT_WEB_PORTAL_CI_PATH init
terraform -chdir=$DPH_PRODUCT_WEB_PORTAL_CI_PATH apply --auto-approve

terraform -chdir=$DPH_PRODUCT_WEB_CONSOLE_CI_PATH init
terraform -chdir=$DPH_PRODUCT_WEB_CONSOLE_CI_PATH apply --auto-approve

if [[ "$DESIRED_STATE" == "down" ]]; then
  # Re-apply to destroy VPC used in CI projects
  terraform -chdir=$DPH_PRODUCT_API_TEST_PATH apply --auto-approve -var vpc_cidr_block=""
  terraform -chdir=$DPH_PRODUCT_PLATFROM_CONFIG_PATH apply --auto-approve
fi
