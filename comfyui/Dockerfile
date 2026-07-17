FROM public.ecr.aws/debian/debian:testing

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/manpreetsnehra/devops-tools/"
LABEL org.opencontainers.image.title="ComyUI"
LABEL org.opencontainers.image.description="Comfyui with distributed custom Node"
LABEL org.opencontainers.image.licenses="MIT"

ARG GPU_API_VERSION=cuda

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl python3-virtualenv && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

RUN useradd -u 1000 -d /opt/comfy comfy

# Defines build arguments for the versions of ComfyUI and ComfyUI Manager to use
RUN export COMFYUI_VERSION=`curl --silent "https://api.github.com/repos/Comfy-Org/ComfyUI/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-` && \
    export COMFYUI_DISTRIBUTED_VERSION=`curl --silent "https://api.github.com/repos/robertvoy/ComfyUI-Distributed/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-`

USER comfy

# Sets the working directory to the ComfyUI directory
WORKDIR /opt/comfy

COPY deploy.sh /opt/comfy/