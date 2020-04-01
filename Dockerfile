FROM mcr.microsoft.com/dotnet/core/sdk:3.1.201-alpine3.11

LABEL tools="docker-image, dotnetsdk, aws, node, docker, bash, alpine, curl, python3, pip3, git"
# version is dotnet
LABEL version="3.1.201"
LABEL description="An Alpine based docker image contains a good combination of commenly used tools\
    to build, package as docker image. \
    tools included: Node, .NetCore SDK, AWS-CLI"

ENV AWS_CLI_VERSION="1.18.33"
ENV NODE_VERSION="8.16.2"
ENV GLIBC="2.30-r0"

# python3 pip3
RUN set -x && \
    apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

# awscli
RUN set -x && \
    apk --no-cache update && \
    apk --no-cache add curl jq make bash ca-certificates groff less git openssh-client && \
    pip3 install --upgrade awscli urllib3 && \
    pip3 --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*

# node
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

# obsolate, use glibc instead.
# # pulumi dependency for alpine https://github.com/pulumi/pulumi/issues/1986
# RUN set -x && \
#     apk add --no-cache curl libc6-compat

# pulumi grpc dependencies for alpine. https://github.com/grpc/grpc/issues/18428#issuecomment-535041155
# exclusive with libc6-compat, but gRPC requires glibc. You should use this, not libc6-compat.
RUN set -x && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC}/glibc-${GLIBC}.apk \
    && apk add --no-cache glibc-${GLIBC}.apk

RUN rm -rf /var/cache/apk/*

WORKDIR /data
