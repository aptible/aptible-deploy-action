FROM buildpack-deps:xenial-curl

ARG CLI_BUILD="194"
ARG CLI_VERSION="0.16.3"
ARG CLI_TIMESTAMP="20191024181014"

WORKDIR /tmp/aptible-cli
RUN curl -fsSLO "https://omnibus-aptible-toolbelt.s3.amazonaws.com/aptible/omnibus-aptible-toolbelt/master/${CLI_BUILD}/pkg/aptible-toolbelt_${CLI_VERSION}%2B${CLI_TIMESTAMP}%7Eubuntu.16.04-1_amd64.deb" && \
      dpkg -i "aptible-toolbelt_${CLI_VERSION}%2B${CLI_TIMESTAMP}%7Eubuntu.16.04-1_amd64.deb"  && \
      rm "aptible-toolbelt_${CLI_VERSION}%2B${CLI_TIMESTAMP}%7Eubuntu.16.04-1_amd64.deb"

WORKDIR /action
COPY entrypoint.sh entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
