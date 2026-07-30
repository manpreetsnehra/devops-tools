#!/usr/bin/bash

BASE_DIR=/home/comfy/ComfyUI
## Setup Virtual Env
virtualenv ${HOME}/.venv

## Download and Extract ComfyUI
if [[ $INSTALL_COMFYUI == "true" ]] || [[ ! -d "${BASE_DIR}/.git" ]]
then
  git clone https://github.com/Comfy-Org/ComfyUI.git
fi

## Install Pytorch
if [[ $GPU_TYPE == 'amd' ]]
then
  ${HOME}/.venv/bin/pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm${ROCM_VERSION}
  ${HOME}/.venv/bin/pip install -r ${BASE_DIR}/requirements.txt -r ${BASE_DIR}/manager_requirements.txt matrix-nio huggingface_hub
elif [[ $GPU_TYPE == 'nvidia' ]]
then
  ${HOME}/.venv/bin/pip install -r ${BASE_DIR}/requirements.txt -r ${BASE_DIR}/manager_requirements.txt matrix-nio huggingface_hub --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}
else
  ${HOME}/.venv/bin/pip install -r ${BASE_DIR}/requirements.txt -r ${BASE_DIR}/manager_requirements.txt matrix-nio huggingface_hub
fi  

if [[ $PERSONAL_CLOUD == 'true' ]] && [[ -f "${BASE_DIR}/user/__manager/config.ini" ]]
then
  sed -i "s/network_mode = public/network_mode = personal_cloud/" ${BASE_DIR}/user/__manager/config.ini 
fi

