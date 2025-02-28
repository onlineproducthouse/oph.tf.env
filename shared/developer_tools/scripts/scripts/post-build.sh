#!/bin/bash

set -euo pipefail

# this script must produce a ReleaseManifest.env for container builds
# a release manifest holds metadata (env variables) required during the release

if [[ $CI_ACTION == "build" ]]; then
  echo "Starting post-build action."

  if [[ "$GIT_BRANCH" == "dev" ]]; then
    echo "No post-build action required for branch: '$GIT_BRANCH'"
    exit 0
  fi

  if [[ "$GIT_BRANCH" == "qa" ]]; then
    echo "Target branch: '$GIT_BRANCH'"
    echo "Target project type: '$PROJECT_TYPE'"

    if [[ "$PROJECT_TYPE" == "client" ]]; then
      # Upload build output
      echo "zip -r $QA_BRANCH_RELEASE_ARTEFACT_KEY $(pwd)"
      zip -r $QA_BRANCH_RELEASE_ARTEFACT_KEY ./

      aws s3 cp "./$QA_BRANCH_RELEASE_ARTEFACT_KEY.zip" "s3://$RELEASE_ARTEFACT_STORE"
    fi

    if [[ "$PROJECT_TYPE" == "container" ]]; then
      echo "Uploading release manifest for: $GIT_BRANCH/$PROJECT_TYPE$/IMAGE_REPOSITORY_NAME"

      echo "DKR_IMAGE=$IMAGE_REGISTRY_BASE_URL/$IMAGE_REPOSITORY_NAME:$CODEBUILD_RESOLVED_SOURCE_VERSION" >$RELEASE_MANIFEST
      zip $QA_BRANCH_RELEASE_ARTEFACT_KEY $RELEASE_MANIFEST

      aws s3 cp "./$QA_BRANCH_RELEASE_ARTEFACT_KEY.zip" "s3://$RELEASE_ARTEFACT_STORE"
    fi

    exit 0
  fi
fi

exit 0
