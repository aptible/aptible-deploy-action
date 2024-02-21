TAG?=$(shell git log --format="%H" -n 1)
PLATFORM?=linux/amd64

image:
	docker buildx build \
		--push \
		--platform $(PLATFORM) \
		-t quay.io/aptible/aptible-deploy-action:$(TAG) \
		.
.PHONY: image
