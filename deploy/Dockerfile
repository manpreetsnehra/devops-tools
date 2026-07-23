FROM public.ecr.aws/docker/library/debian:testing

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/manpreetsnehra/devops-tools"
LABEL org.opencontainers.image.title="CI/CD Tools base"
LABEL org.opencontainers.image.description="CI Tools Image for CI PIpelines"
LABEL org.opencontainers.image.licenses="MIT"

ENV ASPNETCORE_HTTP_PORTS=8080
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DEBIAN_FRONTEND=noninteractive
ARG GITLAB_TOFU_VERSION=4.7.0
    
RUN apt-get -q update -y \
    && apt-get -q install -y --no-install-recommends \
    git \
    openssh-client \
    ansible-lint \
    ansible \
    nodejs \
    idn2 \
    libc6 \
    libgcc-s1 \
    libicu78 \
    libssl3t64 \
    libstdc++6 \
    tzdata \
    tzdata-legacy \
    awscli \
    sudo \
    curl \
    wget \
    gpg \
    jq \
    azure-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## Download Tools
RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /usr/share/keyrings/docker.asc && \
    echo "deb [signed-by=/usr/share/keyrings/docker.asc] https://download.docker.com/linux/debian trixie stable" | tee /etc/apt/sources.list.d/docker.list 

RUN curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey| gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

RUN apt-get update && \
    apt-get install -y docker-ce docker-buildx-plugin helm unzip --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN export HELMFILE_VERSION=$(curl -s "https://api.github.com/repos/helmfile/helmfile/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    wget -q -O /tmp/helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz && \
    tar xfz /tmp/helmfile.tar.gz -C /tmp/ && \
    mv /tmp/helmfile /usr/local/bin/

RUN wget -q -O /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    wget -q -O /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/download/$(curl -sL "https://api.github.com/repos/aquasecurity/tfsec/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/tfsec-linux-amd64 && \
    wget -q -O /usr/local/bin/gitlab-tofu https://gitlab.com/components/opentofu/-/raw/${GITLAB_TOFU_VERSION}/src/gitlab-tofu.sh && \
    chmod +x /usr/local/bin/* 

RUN export TOFU_VERSION=$(curl -s "https://api.github.com/repos/opentofu/opentofu/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    wget -q -O opentofu.deb https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_amd64.deb && \
    dpkg -i opentofu.deb && rm opentofu.deb

RUN useradd -u 1001 -G sudo,docker -d /home/runner runner \
    && echo "%sudo  ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers \
    && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

WORKDIR /home/runner/actions-runner

RUN export RUNNER_VERSION=$(curl -s "https://api.github.com/repos/actions/runner/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    curl -fsSL -o runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./runner.tar.gz && \
    rm runner.tar.gz

RUN export RUNNER_CONTAINER_HOOKS_VERSION=$(curl -s "https://api.github.com/repos/actions/runner-container-hooks/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    curl -fsSL -o runner-container-hooks.zip https://github.com/actions/runner-container-hooks/releases/download/v${RUNNER_CONTAINER_HOOKS_VERSION}/actions-runner-hooks-k8s-${RUNNER_CONTAINER_HOOKS_VERSION}.zip && \
    unzip ./runner-container-hooks.zip -d ./k8s && \
    rm runner-container-hooks.zip
    
RUN export HELM_CHART_TESTING=$(curl -sL "https://api.github.com/repos/helm/chart-testing/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    curl -fsSL https://github.com/helm/chart-testing/releases/download/v${HELM_CHART_TESTING}/chart-testing_${HELM_CHART_TESTING}_linux_amd64.tar.gz | tar xfz - -C /tmp && \
    mv /tmp/ct /usr/local/bin/ && \
    mv /tmp/etc /etc/ct && \
    rm /tmp/* -rf

RUN echo "    StrictHostKeyChecking no" | tee -a /etc/ssh/ssh_config

RUN chown runner:docker /home/runner -R

USER runner
WORKDIR /home/runner

RUN helm plugin install https://github.com/databus23/helm-diff --verify=false && \
    helmfile init --force && \
    rm .cache -rf

