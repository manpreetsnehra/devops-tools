#!/usr/bin/bash -x

### Set Vars
if [[ -z "${BASE_DIR}" ]]; then BASE_DIR=/home/comfy/ComfyUI; fi
if [[ -z "${TEMP_DIR}" ]];then TEMP_DIR=${BASE_DIR}/temp; fi
if [[ -z "${INPUT_DIR}" ]];then INPUT_DIR=${BASE_DIR}/input;fi
if [[ -z "${OUTPUT_DIR}" ]];then OUTPUT_DIR=${BASE_DIR}/output;fi
if [[ -z "${USER_DIR}" ]];then USER_DIR=${BASE_DIR}/user;fi
ls -l 
sudo chown -fR comfy:comfy $BASE_DIR

mkdir -p $BASE_DIR $INPUT_DIR $TEMP_DIR $OUTPUT_DIR $USER_DIR

tar xfz /home/comfy/comfyui.tar.gz -C $BASE_DIR --strip-components=1

mkdir -p ${BASE_DIR}/custom_nodes/ComfyUI-Distributed
tar xfz /home/comfy/comfyui-distributed.tar.gz -C ${BASE_DIR}/custom_nodes/ComfyUI-Distributed --strip-components=1

## Setup Virtual Env
virtualenv ${BASE_DIR}/.venv

## Install Pytorch
if [[ $GPU_TYPE == 'amd' ]]
then
  ${BASE_DIR}/.venv/bin/pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm${ROCM_VERSION}
  ${BASE_DIR}/.venv/bin/pip install --requirement ${BASE_DIR}/requirements.txt --requirement ${BASE_DIR}/manager_requirements.txt
elif [[ $GPU_TYPE == 'nvidia' ]]
then
  ${BASE_DIR}/.venv/bin/pip install --requirement ${BASE_DIR}/requirements.txt --requirement ${BASE_DIR}/manager_requirements.txt --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}
else
  ${BASE_DIR}/.venv/bin/pip install --requirement ${BASE_DIR}/requirements.txt --requirement ${BASE_DIR}/manager_requirements.txt
fi  

if [[ $GPU_TYPE == 'amd' ]] || [[ $GPU_TYPE == 'nvidia' ]]
then
    ${BASE_DIR}/.venv/bin/python ${BASE_DIR}/main.py \
        --enable-cors-header \
        --disable-auto-launch \
        --base-directory ${BASE_DIR} \
        --temp-directory ${TEMP_DIR} \
        --output-directory ${OUTPUT_DIR} \
        --input-directory ${INPUT_DIR} \
        --user-directory ${USER_DIR} \
        --enable-manager \
        --listen 127.0.0.1 \
        --port 8188
else
    ${BASE_DIR}/.venv/bin/python ${BASE_DIR}/main.py \
        --enable-cors-header \
        --disable-auto-launch \
        --base-directory ${BASE_DIR} \
        --temp-directory ${TEMP_DIR} \
        --output-directory ${OUTPUT_DIR} \
        --input-directory ${INPUT_DIR} \
        --user-directory ${USER_DIR} \
        --enable-manager \
        --cpu \
        --listen 127.0.0.1 \
        --port 8188
fi