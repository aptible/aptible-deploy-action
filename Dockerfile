FROM buildpack-deps:xenial-curl

RUN apt-get update && apt-get install -y --no-install-recommends \
		jq \
		u2f-host \
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/aptible-cli
RUN CLI_FILE="aptible-toolbelt_latest_ubuntu-1604_amd64.deb" && \
    curl -fsSLO "https://omnibus-aptible-toolbelt.s3.us-east-1.amazonaws.com/aptible/omnibus-aptible-toolbelt/latest/${CLI_FILE}" && \
    dpkg -i "${CLI_FILE}"  && \
    rm "${CLI_FILE}"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
