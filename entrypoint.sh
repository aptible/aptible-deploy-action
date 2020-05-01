#!/usr/bin/env bash
set -o errexit

if [ -z "$APTIBLE_ROBOT_USERNAME" ]; then
  echo "Aborting: APTIBLE_ROBOT_USERNAME is not set"
  exit 1
fi

if [ -z "$APTIBLE_ROBOT_PASSWORD" ]; then
  echo "Aborting: APTIBLE_ROBOT_PASSWORD is not set"
  exit 1
fi

if [ -z "$APTIBLE_ENVIRONMENT" ]; then
  echo "Aborting: APTIBLE_ENVIRONMENT is not set"
  exit 1
fi

if [ -z "$APTIBLE_APP" ]; then
  echo "Aborting: APTIBLE_APP is not set"
  exit 1
fi

if [ -z "$DOCKER_IMG" ]; then
  echo "Aborting: DOCKER_IMG is not set"
  exit 1
fi

aptible login \
  --email "$APTIBLE_ROBOT_USERNAME" \
  --password "$APTIBLE_ROBOT_PASSWORD"

if ! APTIBLE_OUTPUT_FORMAT=json aptible apps | jq -e ".[] | select(.handle == \"$APTIBLE_APP\") | select(.environment.handle == \"$APTIBLE_ENVIRONMENT\")" > /dev/null; then
  echo "$0: skip (could not find app $APTIBLE_APP)" >&2
  exit 0
fi

aptible deploy --environment "$APTIBLE_ENVIRONMENT" \
               --app "$APTIBLE_APP" --docker-image "$DOCKER_IMG"