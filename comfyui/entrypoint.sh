#!/usr/bin/bash -x

BASE_DIR=/home/comfy/ComfyUI-master

if [[ -z "${TEMP_DIR}" ]];then TEMP_DIR="${BASE_DIR}/temp"; fi
if [[ -z "${INPUT_DIR}" ]];then INPUT_DIR="${BASE_DIR}/input";fi
if [[ -z "${OUTPUT_DIR}" ]];then OUTPUT_DIR="${BASE_DIR}/output";fi
if [[ -z "${USER_DIR}" ]];then USER_DIR="${BASE_DIR}/user";fi

mkdir $USER_DIR

CUSTOM_TEMP="--temp-directory $TEMP_DIR"
CUSTOM_INPUT="--input-directory $INPUT_DIR"
CUSTOM_OUTPUT="--output-directory $OUTPUT_DIR"
CUSTOM_USER="--user-directory $USER_DIR"

### Set Vars
if [[ -z "${BASE_DIR}" ]]; then BASE_DIR=/home/comfy/ComfyUI-master; fi

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