FROM public.ecr.aws/docker/library/debian:testing

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/manpreetsnehra/devops-tools/"
LABEL org.opencontainers.image.title="Code Server"
LABEL org.opencontainers.image.description="Code Server with various apps inbuilt"
LABEL org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    dumb-init \
    git \
    locales \
    openssh-client \
    procps \
    sudo \
    wget \
    vim \
    idn2 \
    jq \
    ca-certificates \
    apt-transport-https \
    gnupg \
    unzip \
    virtualenv \
    awscli \
    azure-cli && \
    apt-get -y purge nano \
    && rm -rf /var/lib/apt/lists/*

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8

RUN if grep -q 1000 /etc/passwd; then \
    userdel -r "$(id -un 1000)"; \
    fi && \
    useradd -u 1000 -s /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /usr/share/keyrings/docker.asc && \
    echo "deb [signed-by=/usr/share/keyrings/docker.asc] https://download.docker.com/linux/debian trixie stable" | tee /etc/apt/sources.list.d/docker.list 

RUN curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey| gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

RUN apt-get update && \
    apt-get install google-cloud-cli docker-ce-cli docker-buildx-plugin docker-compose-plugin helm --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN export HELM_VERSION=$(curl -sL "https://api.github.com/repos/helm/helm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -fsSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar xfz - -C /tmp/ && \
    mv /tmp/linux-amd64/helm /usr/local/bin/ && \
    export HELM_CHART_TESTING=$(curl -sL "https://api.github.com/repos/helm/chart-testing/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    curl -fsSL https://github.com/helm/chart-testing/releases/download/v${HELM_CHART_TESTING}/chart-testing_${HELM_CHART_TESTING}_linux_amd64.tar.gz | tar xfz - -C /tmp && \
    mv /tmp/ct /usr/local/bin/ && mv /tmp/etc /etc/ct

RUN wget --quiet -O /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    wget --quiet -O /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/download/$(curl -sL "https://api.github.com/repos/aquasecurity/tfsec/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/tfsec-linux-amd64 && \
    chmod +x /usr/local/bin/* 

RUN export CODESERVER_VERSION=$(curl -s "https://api.github.com/repos/coder/code-server/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    wget -q https://github.com/coder/code-server/releases/download/v${CODESERVER_VERSION}/code-server_${CODESERVER_VERSION}_amd64.deb && \
    export GHCLI_VERSION=$(curl -s "https://api.github.com/repos/cli/cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    wget -q https://github.com/cli/cli/releases/download/v${GHCLI_VERSION}/gh_${GHCLI_VERSION}_linux_amd64.deb && \
    export TOFU_VERSION=$(curl -s "https://api.github.com/repos/opentofu/opentofu/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    wget -q https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_amd64.deb && \
    dpkg -i code-server_${CODESERVER_VERSION}_amd64.deb gh_${GHCLI_VERSION}_linux_amd64.deb tofu_${TOFU_VERSION}_amd64.deb && \
    rm gh_${GHCLI_VERSION}_linux_amd64.deb code-server_${CODESERVER_VERSION}_amd64.deb tofu_${TOFU_VERSION}_amd64.deb

EXPOSE 8080
# This way, if someone sets $DOCKER_USER, docker-exec will still work as
# the uid will remain the same. note: only relevant if -u isn't passed to
# docker-run.
USER 1000
WORKDIR /home/coder

ENTRYPOINT ["dumb-init", "/usr/bin/code-server", "$@", "--bind-addr", "0.0.0.0:8080", "."]

