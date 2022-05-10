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

* `username` - passed to `aptible` CLI
* `password` - passed to `aptible` CLI
* `environment` - specifies App to be deployed
* `app` - specifies App to be deployed
* `docker_img` - the name of the image you’d like to deploy, including its repository and tag
### Optional input

* `private_registry_username` - the username for the private registry to pull a docker image from
* `private_registry_password` - the password for the private registry to pull a docker image from

## Outputs

* `status` - success/failure of the deploy

## Example github actions usage
Assumes you have set [secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) (recommended).
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Deploy to Aptible
      uses: aptible/aptible-deploy-action@v1
      with:
        username: ${{ secrets.APTIBLE_USERNAME }}
        password: ${{ secrets.APTIBLE_PASSWORD }}
        environment: <environment name>
        app: <app name>
        docker_img: <docker image name>
        private_registry_username: ${{ secrets.REGISTRY_USERNAME }}
        private_registry_password: ${{ secrets.REGISTRY_PASSWORD }}
```
