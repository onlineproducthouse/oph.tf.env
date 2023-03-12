#!/bin/bash

set -euo pipefail

# Parameters

EMPTY_PARAMETER="-1"

DESIRED_STATE=${1:=$EMPTY_PARAMETER}

if [[ "$DESIRED_STATE" == "$EMPTY_PARAMETER" ]]; then
  echo "missing required parameter: DESIRED_STATE"
  echo "parameter DESIRED_STATE must either be:"
  echo " - up, OR"
  echo " - down"
  exit 0
fi

# prepare

DPH_PRODUCT_SHORT_NAME="dph"

DPH_PLATFORM_STATE_SCRIPT_NAME="product.platform.state.sh"
DPH_PLATFORM_STATE_SCRIPT_PATH="$(pwd)/$DPH_PLATFORM_STATE_SCRIPT_NAME"

# Download execution script
aws s3 cp "s3://dph-developer-tools/dph/scripts/$DPH_PLATFORM_STATE_SCRIPT_NAME" $DPH_PLATFORM_STATE_SCRIPT_PATH

# Apply
bash $(echo $DPH_PLATFORM_STATE_SCRIPT_PATH) $DESIRED_STATE $DPH_PRODUCT_SHORT_NAME

# Clean up
rm -rf $(echo $DPH_PLATFORM_STATE_SCRIPT_PATH)
