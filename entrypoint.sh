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
  BRANCH="$GITHUB_HEAD_REF"
  if [ -z "$BRANCH" ]; then
    BRANCH="$GITHUB_REF_NAME"
  fi
  if [ -z "$BRANCH" ]; then
    echo "Aborting: branch is not set; this shouldn't happen, please contact support: https://www.aptible.com/docs/support"
    exit 1
  fi

  echo "[primetime.aptible.com]:43022 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClUA3SfI+5YthgM/tZ2k1oCYgK+8KbhbVeMdhgHqyKuY/lh7If13MBpxJzyRWs7YEJc+I0D1y3BRQlUe5+xBp4yYKCsbzKJDIvIx/fWWYQugrtxCskXxCQreNzONoB3ibaHQ21N1xCMk+CgLeu+PpCwb1bOxnu+aoz6o73NdOZLnlvadGlojs59datshEyY+l/ZikZ2TIOZUqdzrF3ValivNV9dQeskNLIYdlKkjoO/E+xg/wV9T8LMFa1VXqWiF9+LWuoiCfGqfk6Xz33DPrADtiMKOJj9uWshwxr5L2HAN+aLz2SAW9aaDwHObLMkThhtwJ3qOg+QGGzVOZQpxkOShYb5ByemhKKL6fHo5c2wVOq0QCmoaG/GfGZm24dRdBgj2GHrr1BAQCIN6LDYVU/NHOAgOzdgsGljbtrZ6RGx9waE/QYCnnG6rUz0o7Y+cQOotiQvu2CxOccpkiwwn+olkCrzrApWgs4yloM7mfvsXjCctJHv7ClwUP/iiYpxkc=" >> ./known_hosts
  echo "[primetime.aptible.com]:43022 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEHFh32OAG4rBx9Nisn2RBVbVxkKNrWi/4M6Q44fVwKZEFSUaAJifIk97zd8MhFcsV1WfvOUGIH3s9Png/mWh3A=" >> ./known_hosts
  export ACCESS_TOKEN=$(cat "$HOME/.aptible/tokens.json" | jq '.["https://auth.aptible.com"]' -r)
  REMOTE_URL="root@$INPUT_GIT_REMOTE:$INPUT_ENVIRONMENT/$INPUT_APP.git"
  git remote add aptible ${REMOTE_URL}
  REMOTE_BRANCH="deploy-$(date "+%s")"
  GIT_SSH_COMMAND="ssh -o SendEnv=ACCESS_TOKEN -o PubkeyAuthentication=no -o UserKnownHostsFile=./known_hosts -p 43022" git push aptible "$BRANCH:$REMOTE_BRANCH"

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
