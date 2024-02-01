FROM buildpack-deps:xenial-curl

ARG CLI_BUILD="217"
ARG CLI_VERSION="0.16.7"
ARG CLI_TIMESTAMP="20200812001454"

RUN apt-get update && apt-get install -y --no-install-recommends \
		jq \
		u2f-host \
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/aptible-cli
RUN CLI_FILE="aptible-toolbelt_${CLI_VERSION}%2B${CLI_TIMESTAMP}~ubuntu.16.04-1_amd64.deb" && \
    curl -fsSLO "https://omnibus-aptible-toolbelt.s3.amazonaws.com/aptible/omnibus-aptible-toolbelt/master/${CLI_BUILD}/pkg/${CLI_FILE}" && \
    dpkg -i "${CLI_FILE}"  && \
    rm "${CLI_FILE}"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
