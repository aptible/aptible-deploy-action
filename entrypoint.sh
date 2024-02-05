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
  echo "[primetime.aptible.com]:43022 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqkrJJ7YE0MV/x0PcWsCdAjDIZQcicSLnDdn8s8GbdektPGsW/rw+rXMYx8Xb4IEGzfgY5Y5lJVwkV5B0BFr4xMX4zgkYf4f/PmJjCu5UuU3PZwAH85UPB0OYk62ixEOxAt6A7Y6TyvlUPB1CU6LYLAVSqtF0F/z1tUA+Nqhx3Ggp/jthvhKXFgLJN1zzEmR1+Kx2qSZYKD7mnkv/S+ARmOmJgy4ZpowTb3ZIbYvWQIZzWSjMevVeTq/nak3CeCSn/AO/s3odBGtdS3dUY8b3UzccndAZtpqrdy6m7L9ZkrFDR4pxcjBSwcpNpLeIZSXaTXQted5GnqKMQjQQTXyuF" >> ./known_hosts
  echo "[primetime.aptible.com]:43022 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNI5kkrUH3BcV3tNnXvA+BOaH33jYfgbgnOFFd3XK6T/agNaWpVdIOYi+yZkP+j+DWS6sNCtqST9L3y3WtacZgQ=" >> ./known_hosts
  export ACCESS_TOKEN=$(cat "$HOME/.aptible/tokens.json" | jq '.["https://auth.aptible.com"]' -r)
  REMOTE_URL="root@$INPUT_GIT_REMOTE:$INPUT_ENVIRONMENT/$INPUT_APP.git"
  git remote add aptible ${REMOTE_URL}
  REMOTE_BRANCH="deploy-$(date "+%s")"
  GIT_SSH_COMMAND="ssh -o SendEnv=ACCESS_TOKEN -o PubkeyAuthentication=no -o UserKnownHostsFile=./known_hosts -p 43022" git push aptible "$INPUT_BRANCH:$REMOTE_BRANCH"

  aptible deploy --environment "$INPUT_ENVIRONMENT" \
                 --app "$INPUT_APP" \
                 --git-commitish "$REMOTE_BRANCH" \
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
