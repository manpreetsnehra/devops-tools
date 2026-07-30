FROM public.ecr.aws/debian/debian:testing

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/manpreetsnehra/devops-tools/"
LABEL org.opencontainers.image.title="ComyUI"
LABEL org.opencontainers.image.description="Comfyui with distributed custom Node"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl python3-virtualenv sudo git git-lfs unzip screen wget aria2 procps cron libgl1 && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

RUN useradd -u 1000 -G sudo -s /usr/bin/bash -d /home/comfy comfy \
    && echo "%sudo  ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers \
    && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers
    
# Defines build arguments for the versions of ComfyUI and ComfyUI Manager to use
USER comfy

# Sets the working directory to the ComfyUI directory
WORKDIR /home/comfy

RUN git clone https://github.com/Comfy-Org/ComfyUI.git

COPY --chmod=+x --chown=comfy:comfy entrypoint.sh /home/comfy/
COPY --chmod=+x --chown=comfy:comfy install-dependencies.sh /home/comfy/
COPY --chmod=+x --chown=comfy:comfy update-nodes.sh /etc/cron.hourly/

EXPOSE 8188

ENTRYPOINT ["/home/comfy/entrypoint.sh"]