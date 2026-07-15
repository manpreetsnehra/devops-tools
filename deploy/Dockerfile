FROM ghcr.io/actions/actions-runner:latest

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.title="CI/CD Tools base"
LABEL org.opencontainers.image.description="CI Tools Image for CI PIpelines"

ARG TARGETARCH
ARG HELMFILE_VERSION
ARG KUBECTL_VERSION
ARG GITLAB_TOFU_VERSION

RUN sudo apt-get -q update -y \
    && sudo apt-get -q install -y --no-install-recommends sudo \
    lsb-release \
    gpg-agent \
    software-properties-common \
    curl \
    jq \
    unzip \
    git \
    openssh-client \
    ansible-lint \
    ansible \
    nodejs \    
    python3-yaml \
    python3-kubernetes \
    idn2 \
    awscli \
    azure-cli \
    && sudo rm -rf /var/lib/apt/lists/*

WORKDIR /home/runner/tools

## Download Tools
RUN curl -sLo kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH:-amd64}/kubectl"
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 && \
    curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh && \
    chmod +x install-opentofu.sh get_helm.sh && \
    ./get_helm.sh && ./install-opentofu.sh --install-method standalone && \
    rm -f install-opentofu.sh get_helm.sh
RUN curl -sfLo gitlab-tofu https://gitlab.com/components/opentofu/-/raw/${GITLAB_TOFU_VERSION}/src/gitlab-tofu.sh
RUN curl -sfLo helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_${TARGETARCH}.tar.gz
RUN chmod +x *

RUN ls -l && sudo cp * /usr/local/bin/

USER runner
WORKDIR /home/runner

RUN /usr/local/bin/helm plugin install https://github.com/databus23/helm-diff --verify=false && helmfile init --force && sudo rm .cache -rf

RUN echo "    StrictHostKeyChecking no" | sudo tee -a /etc/ssh/ssh_config

