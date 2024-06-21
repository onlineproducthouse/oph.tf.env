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

OPH_PRODUCT_SHORT_NAME=$PRODUCT_SHORT_NAME

OPH_PRODUCT_PLATFROM_CONFIG_PATH="./global/config"
OPH_PRODUCT_SERVICE_FOLDER="$(pwd)/service"

OPH_PRODUCT_API_NAME="$OPH_PRODUCT_SHORT_NAME-api"
OPH_PRODUCT_DATABASE_NAME="$OPH_PRODUCT_SHORT_NAME-database"
OPH_PRODUCT_WEB_STORYBOOK_NAME="$OPH_PRODUCT_SHORT_NAME-web-storybook"
OPH_PRODUCT_WEB_WWW_NAME="$OPH_PRODUCT_SHORT_NAME-web-www"
OPH_PRODUCT_WEB_PORTAL_NAME="$OPH_PRODUCT_SHORT_NAME-web-portal"
OPH_PRODUCT_WEB_CONSOLE_NAME="$OPH_PRODUCT_SHORT_NAME-web-console"

OPH_PRODUCT_API_QA_PATH="$OPH_PRODUCT_SERVICE_FOLDER/$OPH_PRODUCT_API_NAME/qa"

OPH_PRODUCT_API_CI_PATH="$OPH_PRODUCT_SERVICE_FOLDER/$OPH_PRODUCT_API_NAME/ci"
OPH_PRODUCT_DATABASE_CI_PATH="$OPH_PRODUCT_SERVICE_FOLDER/$OPH_PRODUCT_DATABASE_NAME/ci"
OPH_PRODUCT_WEB_STORYBOOK_CI_PATH="$OPH_PRODUCT_SERVICE_FOLDER/$OPH_PRODUCT_WEB_STORYBOOK_NAME/ci"
OPH_PRODUCT_WEB_WWW_CI_PATH="$OPH_PRODUCT_SERVICE_FOLDER/$OPH_PRODUCT_WEB_WWW_NAME/ci"
OPH_PRODUCT_WEB_PORTAL_CI_PATH="$OPH_PRODUCT_SERVICE_FOLDER/$OPH_PRODUCT_WEB_PORTAL_NAME/ci"
OPH_PRODUCT_WEB_CONSOLE_CI_PATH="$OPH_PRODUCT_SERVICE_FOLDER/$OPH_PRODUCT_WEB_CONSOLE_NAME/ci"

OPH_VPC_IN_USE=false
if [[ "$DESIRED_STATE" == "up" ]]; then
  OPH_VPC_IN_USE=true
fi

# init modules
echo "Initialising path - $OPH_PRODUCT_API_QA_PATH"
terraform -chdir=$OPH_PRODUCT_API_QA_PATH init
echo "Done."

echo "Initialising path - $OPH_PRODUCT_PLATFROM_CONFIG_PATH"
terraform -chdir=$OPH_PRODUCT_PLATFROM_CONFIG_PATH init
echo "Done."

echo "Initialising path - $OPH_PRODUCT_API_CI_PATH"
terraform -chdir=$OPH_PRODUCT_API_CI_PATH init
echo "Done."

echo "Initialising path - $OPH_PRODUCT_DATABASE_CI_PATH"
terraform -chdir=$OPH_PRODUCT_DATABASE_CI_PATH init
echo "Done."

echo "Initialising path - $OPH_PRODUCT_WEB_STORYBOOK_CI_PATH"
terraform -chdir=$OPH_PRODUCT_WEB_STORYBOOK_CI_PATH init
echo "Done."

echo "Initialising path - $OPH_PRODUCT_WEB_WWW_CI_PATH"
terraform -chdir=$OPH_PRODUCT_WEB_WWW_CI_PATH init
echo "Done."

echo "Initialising path - $OPH_PRODUCT_WEB_PORTAL_CI_PATH"
terraform -chdir=$OPH_PRODUCT_WEB_PORTAL_CI_PATH init
echo "Done."

echo "Initialising path - $OPH_PRODUCT_WEB_CONSOLE_CI_PATH"
terraform -chdir=$OPH_PRODUCT_WEB_CONSOLE_CI_PATH init
echo "Done."

# apply modules
echo "Applying path - $OPH_PRODUCT_API_QA_PATH"
terraform -chdir=$OPH_PRODUCT_API_QA_PATH apply --auto-approve -var run=$OPH_VPC_IN_USE
echo "Done."

echo "Applying path - $OPH_PRODUCT_PLATFROM_CONFIG_PATH"
terraform -chdir=$OPH_PRODUCT_PLATFROM_CONFIG_PATH apply --auto-approve
echo "Done."

echo "Applying path - $OPH_PRODUCT_API_CI_PATH"
terraform -chdir=$OPH_PRODUCT_API_CI_PATH apply --auto-approve
echo "Done."

echo "Applying path - $OPH_PRODUCT_DATABASE_CI_PATH"
terraform -chdir=$OPH_PRODUCT_DATABASE_CI_PATH apply --auto-approve
echo "Done."

echo "Applying path - $OPH_PRODUCT_WEB_STORYBOOK_CI_PATH"
terraform -chdir=$OPH_PRODUCT_WEB_STORYBOOK_CI_PATH apply --auto-approve
echo "Done."

echo "Applying path - $OPH_PRODUCT_WEB_WWW_CI_PATH"
terraform -chdir=$OPH_PRODUCT_WEB_WWW_CI_PATH apply --auto-approve
echo "Done."

echo "Applying path - $OPH_PRODUCT_WEB_PORTAL_CI_PATH"
terraform -chdir=$OPH_PRODUCT_WEB_PORTAL_CI_PATH apply --auto-approve
echo "Done."

echo "Applying path - $OPH_PRODUCT_WEB_CONSOLE_CI_PATH"
terraform -chdir=$OPH_PRODUCT_WEB_CONSOLE_CI_PATH apply --auto-approve
echo "Done."

if [[ "$DESIRED_STATE" == "down" ]]; then
  # Re-apply to destroy VPC used in CI projects
  echo "Reapplying..."
  terraform -chdir=$OPH_PRODUCT_API_QA_PATH apply --auto-approve -var run=false
  terraform -chdir=$OPH_PRODUCT_PLATFROM_CONFIG_PATH apply --auto-approve
  echo "Done."
fi
