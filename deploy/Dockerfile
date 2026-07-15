FROM ghcr.io/actions/actions-runner:latest

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.title="CI/CD Tools base"
LABEL org.opencontainers.image.description="CI Tools Image for CI PIpelines"

RUN sudo apt-get -q update -y \
    && sudo apt-get -q install -y --no-install-recommends \
    git \
    openssh-client \
    ansible-lint \
    ansible \
    nodejs \
    python3-yaml \
    python3-kubernetes \
    python3-botocore \
    python3-boto3 \
    idn2 \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
ARG HELMFILE_VERSION
ARG HELM_VERSION
ARG GITLAB_TOFU_VERSION
ARG KUBECTL_VERSION

## Download Tools
RUN curl -fsSL -o kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH:-amd64}/kubectl
RUN curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 && chmod 700 /tmp/get_helm.sh && sudo /tmp/get_helm.sh
RUN curl -sfLo gitlab-tofu https://gitlab.com/components/opentofu/-/raw/${GITLAB_TOFU_VERSION}/src/gitlab-tofu.sh
RUN curl -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh \
    && chmod +x install-opentofu.sh \
    && sudo ./install-opentofu.sh --install-method standalone --skip-verify \
    && rm -f install-opentofu.sh
RUN sudo mv kubectl gitlab-tofu /usr/local/bin/
RUN sudo chmod +x /usr/local/bin/*

RUN curl -sfL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip -qq awscliv2.zip && sudo ./aws/install && rm awscliv2.zip aws -rf

USER runner
WORKDIR /home/runner

RUN helm plugin install https://github.com/databus23/helm-diff --verify=false && helmfile init --force && sudo rm .cache -rf

RUN echo "    StrictHostKeyChecking no" | sudo tee -a /etc/ssh/ssh_config