FROM ghcr.io/coder/code-server:latest

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/iaacautomation/devops-tools/tree/main/codeserver"
LABEL org.opencontainers.image.title="Code Server"
LABEL org.opencontainers.image.description="Code Server with various apps inbuilt"

RUN sudo apt-get update && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y purge nano && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install idn2 \
    jq \
    ca-certificates \
    apt-transport-https \
    gnupg \
    unzip \
    virtualenv \
    awscli \
    azure-cli && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

ENV HELM_BUILDKITE_APT_KEY_ID="DDF78C3E6EBB2D2CC223C95C62BA89D07698DBC6"    
#### Add and install apt repos

RUN curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /usr/share/keyrings/opentofu.gpg >/dev/null && \
    curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /usr/share/keyrings/opentofu-repo.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/opentofu.gpg,/usr/share/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee /etc/apt/sources.list.d/opentofu.list

RUN curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /usr/share/keyrings/docker.asc && \
    echo "deb [signed-by=/usr/share/keyrings/docker.asc] https://download.docker.com/linux/debian trixie stable" | sudo tee /etc/apt/sources.list.d/docker.list 
    
RUN sudo apt-get update && \
    sudo apt-cache search docker-ce && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get install google-cloud-cli helm tofu docker-ce-cli docker-buildx-plugin docker-compose-plugin --no-install-recommends && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

ARG TFSEC_VERSION
ARG KUBECTL_VERSION

RUN sudo wget --quiet -O /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
RUN sudo wget --quiet -O /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 && \
    sudo chmod +x /usr/local/bin/*
