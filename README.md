# Github Action to deploy onto Aptible Deploy

This action deploys a Docker image to [Aptible Deploy](https://www.aptible.com/deploy/). To use this image, you
should use another workflow step to publish your image to a Docker image registry.

If you are using a private registry, you can setup [Private Registry Authentication](https://www.aptible.com/documentation/deploy/reference/apps/image/private-registry-authentication.html) once ahead of time using the [Aptible CLI](https://www.aptible.com/documentation/deploy/cli.html#cli).

```bash
aptible config:set \
  --app "$APP_HANDLE" \
  "APTIBLE_PRIVATE_REGISTRY_USERNAME=$USERNAME"
  "APTIBLE_PRIVATE_REGISTRY_PASSWORD=$PASSWORD"
```

## Required input and output arguments

## Optional input and output arguments

## Secrets the action uses

## Environment variables the action uses
* `APTIBLE_ROBOT_USERNAME` - passed to `aptible` CLI
* `APTIBLE_ROBOT_PASSWORD` - passed to `aptible` CLI
* `APTIBLE_ENVIRONMENT` - specifies App to be deployed
* `APTIBLE_APP` - specifies App to be deployed
* `DOCKER_IMG` - the name of the image you’d like to deploy, including its repository and tag

## Example workflow using the image
