#!/usr/bin/env bash
set -o errexit

if [ -z "$INPUT_GIT_REMOTE" ]; then
  echo "Aborting: git_remote is not set"
  exit 1
fi

if [ -z "$INPUT_PRIVATE_KEY" ]; then
  echo "Aborting: private_key is not set"
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

REMOTE_URL="git@$INPUT_GIT_REMOTE:$INPUT_ENVIRONMENT/$INPUT_APP.git"
echo "${REMOTE_URL}"

echo -e "$INPUT_PRIVATE_KEY" >__TEMP_INPUT_KEY_FILE
chmod 600 __TEMP_INPUT_KEY_FILE
git remote add aptible ${REMOTE_URL}
GIT_SSH_COMMAND="ssh -i __TEMP_INPUT_KEY_FILE -o IdentitiesOnly=yes -o StrictHostKeyChecking=no" git push aptible main
rm __TEMP_INPUT_KEY_FILE
