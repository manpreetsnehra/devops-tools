FROM public.ecr.aws/docker/library/debian:trixie-slim

ARG TARGETPLATFORM
ARG CHANNEL

ENV COMPlus_EnableDiagnostics="0" \
    UMASK="0002" \
    TZ="Etc/UTC" \
    DEBIAN_FRONTEND=noninteractive 

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get -y install \
        bash \
        ca-certificates \
        catatonit \
        coreutils \
        curl \
        sqlite3 \
        libicu* \
        wget \
        jq \
    && \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/* && \
    export WHISPARR_VERSION=$(curl --silent https://api.github.com/repos/Whisparr/Whisparr/releases | jq -r 'map(select(.prerelease)) | first | .tag_name' | cut -b 2-) && \
    echo https://github.com/Whisparr/Whisparr/releases/download/v${WHISPARR_VERSION}/Whisparr.${WHISPARR_VERSION}.linux-x64.tar.gz && \
    wget -O whisparr.tar.gz -q https://github.com/Whisparr/Whisparr/releases/download/v${WHISPARR_VERSION}/Whisparr.${WHISPARR_VERSION}.linux-x64.tar.gz && \
    mkdir -p /app/bin && \
    tar xzf whisparr.tar.gz -C /app/bin --strip-components=1 && \
    rm whisparr.tar.gz && \
    rm -rf /app/bin/Whisparr.Update && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[iaacautomation](https://github.com/iaacautomation)\n" "${WHISPARR_VERSION}"> /app/package_info && \
    chown -R root:root /app && \
    chmod -R 755 /app && \
    rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Whisparr/Whisparr"
