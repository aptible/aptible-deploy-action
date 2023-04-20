# Github Action to deploy onto Aptible Deploy

This action deploys a Docker image to [Aptible](https://www.aptible.com/). To use this image, you should use another workflow step to publish your image to a Docker image registry (for example [Docker's](https://github.com/marketplace/actions/build-and-push-docker-images)).

If you are using a private registry, you can optionally setup [Private Registry Authentication](https://deploy-docs.aptible.com/docs/private-registry-authentication) once ahead of time using the [Aptible CLI](https://deploy-docs.aptible.com/docs/cli). Otherwise, you can pass the credentials directly via the action.

```bash
aptible config:set \
  --app "$APP_HANDLE" \
  "APTIBLE_PRIVATE_REGISTRY_USERNAME=$USERNAME"
  "APTIBLE_PRIVATE_REGISTRY_PASSWORD=$PASSWORD"
```

## Inputs

The following inputs can be used as `step.with` keys

### Required input

- `username` - passed to `aptible` CLI
- `password` - passed to `aptible` CLI
- `environment` - specifies App to be deployed
- `app` - specifies App to be deployed
- `docker_img` - the name of the image you’d like to deploy, including its repository and tag

### Optional input

- `private_registry_username` - the username for the private registry to pull a docker image from
- `private_registry_password` - the password for the private registry to pull a docker image from
- `config_variables` - a space separated list of key=value pairs to set as config variables on the app during deployment

## Outputs

- `status` - success/failure of the deploy

## Example github actions usage

Assumes you have set [secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) (recommended).

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest

      - name: Deploy to Aptible
        uses: aptible/aptible-deploy-action@v1
        with:
          username: ${{ secrets.APTIBLE_USERNAME }}
          password: ${{ secrets.APTIBLE_PASSWORD }}
          environment: <environment name>
          app: <app name>
          docker_img: <docker image name>
          private_registry_username: ${{ secrets.DOCKERHUB_USERNAME }}
          private_registry_password: ${{ secrets.DOCKERHUB_TOKEN }}
          config_variables: KEY1=value1 KEY2=value2
```

## Example with Container Build and Docker Hub

```yaml

env:
  IMAGE_NAME: user/app:latest
  APTIBLE_ENVIRONMENT: "my_environment"
  APTIBLE_APP: "my_app"


jobs:
  deploy:
    runs-on: ubuntu-latest

      # Allow multi platform builds.
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v2

      # Allow use of secrets and other advanced docker features.
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      # Log into Docker Hub
      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Build image using default dockerfile.
      - name: Build and push
        uses: docker/build-push-action@v3
        with:
          push: true
          tags: ${{ env.IMAGE_NAME }}

      - name: Deploy to Aptible
        uses: aptible/aptible-deploy-action@v1
        with:
          username: ${{ secrets.APTIBLE_USERNAME }}
          password: ${{ secrets.APTIBLE_PASSWORD }}
          environment: ${{ env.APTIBLE_ENVIRONMENT }}
          app: ${{ env.APTIBLE_APP }}
          docker_img: ${{ env.IMAGE_NAME }}
          private_registry_username: ${{ secrets.DOCKERHUB_USERNAME }}
          private_registry_password: ${{ secrets.DOCKERHUB_TOKEN }}
          config_variables: RELEASE_SHA=${{ github.sha }}
```
