#!bin/bash

DEPLOY_DIR=${INSTALL_DIR}/deploy

mkdir -p $DEPLOY_DIR $MODELS_DIR

MODEL_DIRECTORIES=(
    "checkpoints"
    "clip"
    "clip_vision"
    "configs"
    "controlnet"
    "diffusers"
    "diffusion_models"
    "embeddings"
    "gligen"
    "hypernetworks"
    "loras"
    "photomaker"
    "style_models"
    "text_encoders"
    "unet"
    "upscale_models"
    "vae"
    "vae_approx"
)
for MODEL_DIRECTORY in ${MODEL_DIRECTORIES[@]}; do
    mkdir -p ${BASE_DIR}/models/
done

## Get Versions
COMFYUI_VERSION=`curl --silent "https://api.github.com/repos/Comfy-Org/ComfyUI/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-`
COMFYUI_DISTRIBUTED_VERSION=`curl --silent "https://api.github.com/repos/robertvoy/ComfyUI-Distributed/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-`

## Get ComfyUI
if [[ ! -d ${DEPLOY_DIR}/ui ]] || [[ $COMFYUI_VERSION != $(cat ${INSTALL_DIR}/COMFYUI_INSTALLED_VERSION) ]]
then
  mkdir -p ${DEPLOY_DIR}/ui
  curl -s -L https://github.com/Comfy-Org/ComfyUI/archive/refs/tags/v${COMFYUI_VERSION}.tar.gz | tar xfz - -C ${DEPLOY_DIR}/ui
  echo $COMFUI_VERSION > ${INSTALL_DIR}/COMFYUI_INSTALLED_VERSION
fi

## Get ComfyUI Distributed
if [[ ! -d ${BASE_DIR}/custom_nodes/ComfyUI-Distributed ]] || [[ $COMFYUI_DISTRIBUTED_VERSION != $(cat ${INSTALL_DIR}/COMFYUI_DISTRIBUTED_INSTALLED_VERSION) ]]
then
  mkdir -p ${BASE_DIR}/custom_nodes/ComfyUI-Distributed
  curl -s -L https://github.com/robertvoy/ComfyUI-Distributed/archive/refs/tags/v${COMFYUI_DISTRIBUTED_VERSION}.tar.gz | tar xfz - -C ${BASE_DIR}/custom_nodes/ComfyUI-Distributed
  echo $COMFUI_DISTRIBUTED_VERSION > ${INSTALL_DIR}/COMFYUI_DISTRIBUTED_INSTALLED_VERSION  
fi

## Setup Virtual Env
virtualenv ${DEPLOY_DIR}/venv

## Activate Python Virtual ENV
source ${DEPLOY_DIR}/venv/bin/activate

## Install Pytorch
if [[ $1 == 'amd' ]]
then
  pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm${ROCM_VERSION}
  pip install --requirement ${DEPLOY_DIR}/ui/requirements.txt --requirement ${DEPLOY_DIR}/ui/manager_requirements.txt
else
  pip install --requirement ${DEPLOY_DIR}/ui/requirements.txt --requirement ${DEPLOY_DIR}/ui/manager_requirements.txt --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}
fi  
