#!/usr/bin/bash -x

BASE_DIR=/home/comfy/ComfyUI

## Setup Virtual Env
virtualenv ${HOME}/.venv

## Install Pytorch
if [[ $GPU_TYPE == 'amd' ]]
then
  ${HOME}/.venv/bin/pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm${ROCM_VERSION}
  ${HOME}/.venv/bin/pip install --requirement ${BASE_DIR}/requirements.txt --requirement ${BASE_DIR}/manager_requirements.txt -r ${BASE_DIR}/custom_nodes/ComfyS3/requirements.txt
elif [[ $GPU_TYPE == 'nvidia' ]]
then
  ${HOME}/.venv/bin/pip install --requirement ${BASE_DIR}/requirements.txt --requirement ${BASE_DIR}/manager_requirements.txt -r ${BASE_DIR}/custom_nodes/ComfyS3/requirements.txt --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}
else
  ${HOME}/.venv/bin/pip install --requirement ${BASE_DIR}/requirements.txt --requirement ${BASE_DIR}/manager_requirements.txt -r ${BASE_DIR}/custom_nodes/ComfyS3/requirements.txt
fi  

${HOME}/.venv/bin/pip install matrix-nio

if [[ $PERSONAL_CLOUD == 'true' ]]
then
  sed -i "s/network_mode = public/network_mode = personal_cloud/" ${BASE_DIR}/user/__manager/config.ini 
fi

if [[ $GPU_TYPE == 'amd' ]] || [[ $GPU_TYPE == 'nvidia' ]]
then
    ${HOME}/.venv/bin/python ${BASE_DIR}/main.py \
        --enable-cors-header '*' \
        --disable-auto-launch \
        --enable-manager \
        --listen 0.0.0.0 \
        --port 8188
else
    ${HOME}/.venv/bin/python ${BASE_DIR}/main.py \
        --enable-cors-header '*' \
        --disable-auto-launch \
        --enable-manager \
        --cpu \
        --listen 0.0.0.0 \
        --port 8188
fi