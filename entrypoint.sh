#!/usr/bin/env bash
set -o errexit

########################################
##### BEGIN FLOW-CONTROLLED FUNCTIONS
########################################

validate_docker_deployment() {
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
}

validate_git_deployment() {
  if [ "$INPUT_GIT_DEPLOYMENT" == 'True' && -z "$INPUT_GIT_SSH_KEY" ]; then 
    echo "Aborting: input_git-deployment is set to true but no git_ssh_key key provided."
  fi
}

execute_docker_deployment() {
  aptible login \
    --email "$INPUT_USERNAME" \
    --password "$INPUT_PASSWORD"
    
  if ! APTIBLE_OUTPUT_FORMAT=json aptible apps | jq -e ".[] | select(.handle == \"$INPUT_APP\") | select(.environment.handle == \"$INPUT_ENVIRONMENT\")" > /dev/null; then
    echo "Could not find app $INPUT_APP in $INPUT_ENVIRONMENT" >&2
    exit 1
  fi

  aptible deploy --environment "$INPUT_ENVIRONMENT" \
                --app "$INPUT_APP" \
                --docker-image "$INPUT_DOCKER_IMG" \
                --private-registry-username "$INPUT_PRIVATE_REGISTRY_USERNAME" \
                --private-registry-password "$INPUT_PRIVATE_REGISTRY_PASSWORD"
}

execute_git_deployment() {
  mkdir -p ~/.ssh 
  echo "$INPUT_GIT_SSH_KEY" | tr -d '\r' > ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  ssh-add ~/.ssh/id_rsa
  ssh-keyscan -H 'beta.aptible.com' >> ~/.ssh/known_hosts
  git push aptible master:$GITHUB_SHA
}

########################################
##### END FLOW-CONTROLLED FUNCTIONS
########################################


if [ -z "$INPUT_DOCKER_IMG" && "$INPUT_GIT_DEPLOYMENT" == 'False' ]; then
  echo "Aborting: docker_img and not a git_deployment! Please set a docker_img or set git_deployment to True."
  exit 1
fi

if [ "$INPUT_GIT_DEPLOYMENT" == "False" ]; then
  validate_docker_deployment()
  execute_docker_deployment()
else
  validate_git_deployment()
  execute_git_deployment()
fi