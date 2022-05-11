FROM quay.io/aptible/aptible-cli:latest as aptible-deps
FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
		git ssh-client \
    && rm -rf /var/lib/apt/lists/*

COPY --from=aptible-deps /opt/aptible-toolbelt /opt/aptible-toolbelt
COPY --from=aptible-deps /usr/local/bin/aptible /usr/local/bin/