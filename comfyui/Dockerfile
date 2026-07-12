FROM public.ecr.aws/debian/debian:13-slim

ARG GPU_API_VERSION

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl python3-virtualenv && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

RUN useradd -u 1000 -d /opt/comfy comfy

# Defines build arguments for the versions of ComfyUI and ComfyUI Manager to use
ARG COMFYUI_VERSION
ARG COMFYUI_DISTRIBUTED_VERSION

USER comfy

# Sets the working directory to the ComfyUI directory
WORKDIR /opt/comfy

COPY deploy.sh /opt/comfy/