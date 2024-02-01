This action helps you deploy Apps to [Aptible](https://www.aptible.com/).

There are two deployment strategies, both are supported in this action:

- [Git Push](#git-push-deploy)
- [Direct Docker Image](#direct-docker-image-deploy)

If you are just getting started at Aptible, the easiest deployment strategy is
[Git Push](#git-push-deploy).

# Git Push Deploy

[Read the docs on this strategy](https://www.aptible.com/docs/dockerfile-deploy).

## Inputs

The following inputs can be used as `step.with` keys

### Required input

- `username` - Aptible email login
- `password` - Aptible password login
- `app` - [Aptible App](https://www.aptible.com/docs/apps) handle
- `environment` -
  [Aptible Environment](https://www.aptible.com/docs/environments) handle the
  App is hosted within

### Optional input

- `config_variables` - [configuration variables to set](https://www.aptible.com/docs/set-configuration-variables)

> [!IMPORTANT]\
> We do **not** recommend setting `config_variables` inside our github action
> because those variables only need to be set once within Aptible for them to
> persist across deployments.
> [Learn more](https://www.aptible.com/docs/set-configuration-variables).

## Example using Git Push

Assumes you have set
[secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
(recommended).

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest

      - name: Deploy to Aptible
        uses: aptible/aptible-deploy-action@v2
        with:
          app: <app name>
          environment: <environment name>
          username: ${{ secrets.APTIBLE_USERNAME }}
          password: ${{ secrets.APTIBLE_PASSWORD }}
```

# Direct Docker Image Deploy

[Read the docs on this strategy](https://www.aptible.com/docs/migrating-from-dockerfile-deploy).

To use this image, you should use another workflow step to publish your image to
a Docker image registry (for example
[Docker's](https://github.com/marketplace/actions/build-and-push-docker-images)).

If you are using a private registry, you can optionally setup
[Private Registry Authentication](https://deploy-docs.aptible.com/docs/private-registry-authentication)
once ahead of time using the
[Aptible CLI](https://deploy-docs.aptible.com/docs/cli). Otherwise, you can pass
the credentials directly via the action.

## Inputs

The following inputs can be used as `step.with` keys

### Required input

- `type` - set to `docker`
- `username` - Aptible email login
- `password` - Aptible password login
- `environment` -
  [Aptible Environment](https://www.aptible.com/docs/environments) handle the
  App is hosted within
- `app` - [Aptible App](https://www.aptible.com/docs/apps) handle
- `docker_img` - the name of the image you'd like to deploy, including its
  repository and tag

### Optional input

- `private_registry_username` - the username for the private image registry
- `private_registry_password` - the password for the private image registry
- `config_variables` - JSON string containing the
  [configuration variables to set](https://www.aptible.com/docs/set-configuration-variables)

> [!IMPORTANT]\
> We do **not** recommend setting `config_variables` inside our github action
> because those variables only need to be set once within Aptible for them to
> persist across deployments.
> [Learn more](https://www.aptible.com/docs/set-configuration-variables).

## Outputs

- `status` - success/failure of the deploy

## Example using Direct Docker Image Deploy

Assumes you have set
[secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
(recommended).

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest

      - name: Deploy to Aptible
        uses: aptible/aptible-deploy-action@v2
        with:
          type: docker 
          app: <app name>
          environment: <environment name>
          username: ${{ secrets.APTIBLE_USERNAME }}
          password: ${{ secrets.APTIBLE_PASSWORD }}
          docker_img: <docker image name>
          private_registry_username: ${{ secrets.DOCKERHUB_USERNAME }}
          private_registry_password: ${{ secrets.DOCKERHUB_TOKEN }}
          config_variables: DEBUG=app:* FORCE_SSL=true 
```

## Example using Container Build and Docker Hub

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
        uses: aptible/aptible-deploy-action@v2
        with:
          type: docker 
          app: ${{ env.APTIBLE_APP }}
          environment: ${{ env.APTIBLE_ENVIRONMENT }}
          username: ${{ secrets.APTIBLE_USERNAME }}
          password: ${{ secrets.APTIBLE_PASSWORD }}
          docker_img: ${{ env.IMAGE_NAME }}
          private_registry_username: ${{ secrets.DOCKERHUB_USERNAME }}
          private_registry_password: ${{ secrets.DOCKERHUB_TOKEN }}
          config_variables: RELEASE_SHA=${{ github.sha }}
```
