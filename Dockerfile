FROM buildpack-deps:noble-curl

RUN apt-get update && apt-get install -y --no-install-recommends \
    jq u2f-host git openssh-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/aptible-cli
RUN CLI_FILE="aptible-cli-go_1.0.1_debian_amd64.deb" && \
    curl -fsSLO "https://omnibus-aptible-toolbelt.s3.us-east-1.amazonaws.com/release/aptible-cli-go/${CLI_FILE}" && \
    dpkg -i "${CLI_FILE}"  && \
    rm "${CLI_FILE}"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
