FROM public.ecr.aws/debian/debian:testing

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/manpreetsnehra/devops-tools/"
LABEL org.opencontainers.image.title="ComyUI"
LABEL org.opencontainers.image.description="Comfyui with distributed custom Node"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl python3-virtualenv sudo && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

RUN useradd -u 1000 -G sudo -d /home/comfy comfy \
    && echo "%sudo  ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers \
    && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers
    
# Defines build arguments for the versions of ComfyUI and ComfyUI Manager to use
USER comfy

# Sets the working directory to the ComfyUI directory
WORKDIR /home/comfy

COPY --chown=comfy:comfy entrypoint.sh /home/comfy/
RUN chmod +x entrypoint.sh

EXPOSE 8188

ENTRYPOINT ["/home/comfy/entrypoint.sh"]