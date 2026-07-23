FROM public.ecr.aws/debian/debian:testing

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/manpreetsnehra/devops-tools/"
LABEL org.opencontainers.image.title="ComyUI"
LABEL org.opencontainers.image.description="Comfyui with distributed custom Node"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl python3-virtualenv sudo git unzip && \
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

RUN curl -fsSL -o comfyui.zip https://github.com/Comfy-Org/ComfyUI/archive/refs/heads/master.zip && \
    unzip -qq /home/comfy/comfyui.zip && \
    rm comfyui.zip 

WORKDIR /home/comfy/ComfyUI-master/custom_nodes/

RUN git clone https://github.com/TemryL/ComfyS3.git && \
    rm ComfyS3/.git -rf

RUN export COMYUI_DISTRIBUTED_VERSION=$(curl -sL "https://api.github.com/repos/robertvoy/ComfyUI-Distributed/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-) && \
    mkdir ComfyUI-Distributed && \
    curl -fsSL https://github.com/robertvoy/ComfyUI-Distributed/archive/refs/tags/v${COMYUI_DISTRIBUTED_VERSION}.tar.gz  | tar xfz - -C ComfyUI-Distributed --strip-components=1

WORKDIR /home/comfy/ComfyUI-master/

EXPOSE 8188

ENTRYPOINT ["/home/comfy/entrypoint.sh"]