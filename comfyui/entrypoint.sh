#!/usr/bin/bash -x

### Set Vars
if [[ -z "${BASE_DIR}" ]]; then BASE_DIR=/home/comfy/ComfyUI-master; fi
if [[ ! -z "${TEMP_DIR}" ]];then CUSTOM_TEMP="--temp-directory $TEMP_DIR"; fi
if [[ ! -z "${INPUT_DIR}" ]];then CUSTOM_INPUT="--input-directory ${INPUT_DIR}";fi
if [[ ! -z "${OUTPUT_DIR}" ]];then CUSTOM_OUTPUT="--input-directory ${OUTPUT_DIR}";fi
if [[ ! -z "${USER_DIR}" ]];then CUSTOM_USER="--input-directory ${USER_DIR}";fi

## Setup Virtual Env
virtualenv ${HOME}/.venv

## Install Pytorch
if [[ $GPU_TYPE == 'amd' ]]
then
  ${HOME}/.venv/bin/pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm${ROCM_VERSION}
  ${HOME}/.venv/bin/pip install --requirement ${BASE_DIR}/requirements.txt --requirement ${BASE_DIR}/manager_requirements.txt
elif [[ $GPU_TYPE == 'nvidia' ]]
then
  ${HOME}/.venv/bin/pip install --requirement ${BASE_DIR}/requirements.txt --requirement ${BASE_DIR}/manager_requirements.txt --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}
else
  ${HOME}/.venv/bin/pip install --requirement ${BASE_DIR}/requirements.txt --requirement ${BASE_DIR}/manager_requirements.txt
fi  

${HOME}/.venv/bin/pip install matrix-nio

if [[ $PERSONAL_CLOUD == 'true' ]]
then
  sed -i "s/network_mode = public/network_mode = personal_cloud/" ${BASE_DIR}/user/__manager/config.ini 
fi

if [[ $GPU_TYPE == 'amd' ]] || [[ $GPU_TYPE == 'nvidia' ]]
then
    ${HOME}/.venv/bin/python ${BASE_DIR}/main.py \
        --enable-cors-header \
        --disable-auto-launch \
        ${CUSTOM_TEMP} \
        ${CUSTOM_INPUT} \
        ${CUSTOM_OUTPUT} \
        ${CUSTOM_USER} \
        --enable-manager \
        --listen 0.0.0.0 \
        --port 8188
else
    ${HOME}/.venv/bin/python ${BASE_DIR}/main.py \
        --enable-cors-header \
        --disable-auto-launch \
        ${CUSTOM_TEMP} \
        ${CUSTOM_INPUT} \
        ${CUSTOM_OUTPUT} \
        ${CUSTOM_USER} \
        --enable-manager \
        --cpu \
        --listen 0.0.0.0 \
        --port 8188
fi