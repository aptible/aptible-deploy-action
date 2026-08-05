FROM buildpack-deps:resolute-curl

WORKDIR /tmp/aptible-cli

RUN apt-get update && apt-get install -y --no-install-recommends \
    jq && rm -rf /var/lib/apt/lists/*

RUN CLI_FILE="aptible-cli-go_latest_ubuntu_amd64.deb" && \
    curl -fsSLO "https://omnibus-aptible-toolbelt.s3.us-east-1.amazonaws.com/prerelease/aptible-cli-go/${CLI_FILE}" && \
    dpkg -i "${CLI_FILE}"  && \
    rm "${CLI_FILE}"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
