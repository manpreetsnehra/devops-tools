FROM public.ecr.aws/docker/library/debian:testing

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/manpreetsnehra/devops-tools/tree/main/codeserver"
LABEL org.opencontainers.image.title="Code Server"
LABEL org.opencontainers.image.description="Code Server with various apps inbuilt"
LABEL org.opencontainers.image.licenses="MIT"

ARG CODER_USER=coder

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
    DEBIAN_FRONTEND=noninteractive apt-get -y purge nano \
    && rm -rf /var/lib/apt/lists/*

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8

RUN if grep -q 1000 /etc/passwd; then \
    userdel -r "$(id -un 1000)"; \
    fi && \
    useradd -u 1000 ${CODER_USER} && \
    echo "${CODER_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /usr/share/keyrings/docker.asc && \
    echo "deb [signed-by=/usr/share/keyrings/docker.asc] https://download.docker.com/linux/debian trixie stable" | tee /etc/apt/sources.list.d/docker.list 

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install google-cloud-cli docker-ce-cli docker-buildx-plugin docker-compose-plugin --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet -O /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    wget --quiet -O /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/download/$(curl -sL "https://api.github.com/repos/aquasecurity/tfsec/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/tfsec-linux-amd64 && \    
    chmod +x /usr/local/bin/* 

RUN export CODESERVER_VERSION=$(curl -s "https://api.github.com/repos/coder/code-server/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    wget -q https://github.com/coder/code-server/releases/download/v${CODESERVER_VERSION}/code-server_${CODESERVER_VERSION}_amd64.deb && \
    export GHCLI_VERSION=$(curl -s "https://api.github.com/repos/cli/cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) \
    wget https://github.com/cli/cli/releases/download/v${GHCLI_VERSION}/gh_${GHCLI_VERSION}_linux_amd64.deb && \
    dpkg -i code-server*_amd64.deb ghcli*.deb && \
    rm *.deb

RUN curl -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh && \
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 && \
    bash -x get_helm.sh && bash -x install-opentofu.sh --install-method standalone && \
    rm -f install-opentofu.sh get_helm.sh


EXPOSE 8080
# This way, if someone sets $DOCKER_USER, docker-exec will still work as
# the uid will remain the same. note: only relevant if -u isn't passed to
# docker-run.
USER 1000
ENV USER=${CODER_USER}
WORKDIR /home/${CODER_USER}

ENTRYPOINT ["dumb-init", "/usr/bin/code-server", "$@", "--bind-addr", "0.0.0.0:8080", "."]

