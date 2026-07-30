#!/usr/bin/bash -x

BASE_DIR=/home/comfy/ComfyUI

if [[ $TYPE != "worker" ]]
then
  source ${HOME}/install-dependencies.sh
fi

cp /home/comfy/update-nodes.sh $BASE_DIR
source ${BASE_DIR}/update-nodes.sh

if [[ $GPU_TYPE == 'amd' ]] || [[ $GPU_TYPE == 'nvidia' ]]
then
    ${HOME}/.venv/bin/python ${HOME}/ComfyUI/main.py \
        --enable-cors-header '*' \
        --disable-auto-launch \
        --enable-manager \
        --listen 0.0.0.0 \
        --port 8188 ${COMFYUI_ARGS}
else
    ${HOME}/.venv/bin/python ${HOME}/ComfyUI/main.py \
        --enable-cors-header '*' \
        --disable-auto-launch \
        --enable-manager \
        --cpu \
        --listen 0.0.0.0 \
        --port 8188 ${COMFYUI_ARGS}
fi