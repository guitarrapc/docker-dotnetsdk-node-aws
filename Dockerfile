FROM mcr.microsoft.com/dotnet/core/sdk:3.0.101-alpine3.10

LABEL tools="docker-image, dotnetsdk, aws, node, docker, bash, alpine, curl, python3, pip3, git"
# version is aws version
LABEL version="1.16.292"
LABEL description="An Alpine based docker image contains a good combination of commenly used tools\
    to build, package as docker image. \
    tools included: Node, .NetCore SDK, AWS-CLI"

ENV AWS_CLI_VERSION="1.16.292"
ENV NODE_VERSION 8.16.2

RUN set -x && \
    apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

RUN set -x && \
    apk --no-cache update && \
    apk --no-cache add curl jq make bash ca-certificates groff less git openssh-client && \
    pip3 install --upgrade awscli urllib3 && \
    pip3 --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*

RUN set -x && \
    apk add --no-cache libstdc++ \
    && apk add --no-cache --virtual .build-deps curl \
    && ARCH= && alpineArch="$(apk --print-arch)" \
    && case "${alpineArch##*-}" in \
    x86_64) \
    ARCH='x64' \
    CHECKSUM="39276723f03e4adaa9f2eeded8653ca6b74d3df23ac70a3455a28c51f0cf0001" \
    ;; \
    *) ;; \
    esac \
    && if [ -n "${CHECKSUM}" ]; then \
    set -eu; \
    curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"; \
    echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
    fi

RUN rm -rf /var/cache/apk/*

WORKDIR /data