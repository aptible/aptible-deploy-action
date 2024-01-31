#!/usr/bin/env bash
set -o errexit

if [ -z "$INPUT_USERNAME" ]; then
  echo "Aborting: username is not set"
  exit 1
fi

if [ -z "$INPUT_PASSWORD" ]; then
  echo "Aborting: password is not set"
  exit 1
fi

if [ -z "$INPUT_ENVIRONMENT" ]; then
  echo "Aborting: environment is not set"
  exit 1
fi

if [ -z "$INPUT_APP" ]; then
  echo "Aborting: app is not set"
  exit 1
fi

aptible login \
  --email "$INPUT_USERNAME" \
  --password "$INPUT_PASSWORD"

if ! APTIBLE_OUTPUT_FORMAT=json aptible apps | jq -e ".[] | select(.handle == \"$INPUT_APP\") | select(.environment.handle == \"$INPUT_ENVIRONMENT\")" > /dev/null; then
  echo "Could not find app $INPUT_APP in $INPUT_ENVIRONMENT" >&2
  exit 1
fi

if [ "$INPUT_TYPE" == "git" ]; then
  if [ -z "$INPUT_PRIVATE_KEY" ]; then
    echo "Aborting: private_key is not set"
    exit 1
  fi

  REMOTE_URL="git@$INPUT_GIT_REMOTE:$INPUT_ENVIRONMENT/$INPUT_APP.git"
  echo -e "$INPUT_PRIVATE_KEY" >__TEMP_INPUT_KEY_FILE
  chmod 600 __TEMP_INPUT_KEY_FILE
  git remote add aptible ${REMOTE_URL}
  BRANCH="deploy-$(date "+%s")"
  GIT_SSH_COMMAND="ssh -i __TEMP_INPUT_KEY_FILE -o IdentitiesOnly=yes -o StrictHostKeyChecking=no" git push aptible "main:$BRANCH"
  rm __TEMP_INPUT_KEY_FILE

  aptible deploy --environment "$INPUT_ENVIRONMENT" \
                 --app "$INPUT_APP" \
                 --git-commitish "$BRANCH" \
                 ${INPUT_CONFIG_VARIABLES}
fi

if [ "$INPUT_TYPE" == "docker" ]; then
  if [ -z "$INPUT_DOCKER_IMG" ]; then
    echo "Aborting: docker_img is not set"
    exit 1
  fi

  aptible deploy --environment "$INPUT_ENVIRONMENT" \
                 --app "$INPUT_APP" \
                 --docker-image "$INPUT_DOCKER_IMG" \
                 --private-registry-username "$INPUT_PRIVATE_REGISTRY_USERNAME" \
                 --private-registry-password "$INPUT_PRIVATE_REGISTRY_PASSWORD" \
                 ${INPUT_CONFIG_VARIABLES}
fi
