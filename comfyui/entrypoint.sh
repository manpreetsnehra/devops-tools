#!/usr/bin/bash -x

### Set Vars
if [[ -z "${INSTALL_DIR}" ]];then INSTALL_DIR=/home/comfy/install; fi
if [[ -z "${BASE_DIR}" ]]; then BASE_DIR=${INSTALL_DIR}/ui; fi
if [[ -z "${TEMP_DIR}" ]];then TEMP_DIR=${BASE_DIR}/temp; fi
if [[ -z "${INPUT_DIR}" ]];then INPUT_DIR=${BASE_DIR}/input;fi
if [[ -z "${OUTPUT_DIR}" ]];then OUTPUT_DIR=${BASE_DIR}/output;fi
if [[ -z "${USER_DIR}" ]];then USER_DIR=${BASE_DIR}/user;fi

sudo chown -f comfy:comfy $INSTALL_DIR $TEMP_DIR $OUTPUT_DIR $INPUT_DIR $USER_DIR $BASE_DIR
mkdir -p $INSTALL_DIR $TEMP_DIR $OUTPUT_DIR $INPUT_DIR $USER_DIR
# Get latest versions
export COMFYUI_VERSION=`curl -fsSL "https://api.github.com/repos/Comfy-Org/ComfyUI/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-` && \
export COMFYUI_DISTRIBUTED_VERSION=`curl -fsSL "https://api.github.com/repos/robertvoy/ComfyUI-Distributed/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'|cut -b 2-`

## Get ComfyUI
if [[ $COMFYUI_VERSION != $(cat ${INSTALL_DIR}/COMFYUI_INSTALLED_VERSION) ]]
then
  mkdir -p ${INSTALL_DIR}/ui
  curl -s -L https://github.com/Comfy-Org/ComfyUI/archive/refs/tags/v${COMFYUI_VERSION}.tar.gz | tar xfz - -C ${INSTALL_DIR}/ui --strip-components=1
  echo $COMFUI_VERSION > ${INSTALL_DIR}/COMFYUI_INSTALLED_VERSION
fi

## Get ComfyUI Distributed
if [[ ! -d ${BASE_DIR}/custom_nodes/ComfyUI-Distributed ]] || [[ $COMFYUI_DISTRIBUTED_VERSION != $(cat ${INSTALL_DIR}/COMFYUI_DISTRIBUTED_INSTALLED_VERSION) ]]
then
  mkdir -p ${BASE_DIR}/custom_nodes/ComfyUI-Distributed
  curl -s -L https://github.com/robertvoy/ComfyUI-Distributed/archive/refs/tags/v${COMFYUI_DISTRIBUTED_VERSION}.tar.gz | tar xfz - -C ${BASE_DIR}/custom_nodes/ComfyUI-Distributed --strip-components=1
  echo $COMFUI_DISTRIBUTED_VERSION > ${INSTALL_DIR}/COMFYUI_DISTRIBUTED_INSTALLED_VERSION  
fi

## Setup Virtual Env
virtualenv ${INSTALL_DIR}/venv

## Install Pytorch
if [[ $GPU_TYPE == 'amd' ]]
then
  ${INSTALL_DIR}/venv/bin/pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm${ROCM_VERSION}
  ${INSTALL_DIR}/venv/bin/pip install --requirement ${INSTALL_DIR}/ui/requirements.txt --requirement ${INSTALL_DIR}/ui/manager_requirements.txt
elif [[ $GPU_TYPE == 'nvidia' ]]
then
  ${INSTALL_DIR}/venv/bin/pip install --requirement ${INSTALL_DIR}/ui/requirements.txt --requirement ${INSTALL_DIR}/ui/manager_requirements.txt --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}
else
  ${INSTALL_DIR}/venv/bin/pip install --requirement ${INSTALL_DIR}/ui/requirements.txt --requirement ${INSTALL_DIR}/ui/manager_requirements.txt
fi  

if [[ $GPU_TYPE == 'amd' ]] || [[ $GPU_TYPE == 'nvidia' ]]
then
    ${INSTALL_DIR}/venv/bin/python ${INSTALL_DIR}/ui/main.py \
        --enable-cors-header \
        --disable-auto-launch \
        --base-directory ${BASE_DIR} \
        --temp-directory ${TEMP_DIR} \
        --output-directory ${OUTPUT_DIR} \
        --input-directory ${INPUT_DIR} \
        --user-directory ${USER_DIR} \
        --listen 127.0.0.1 \
        --port 8188
else
    ${INSTALL_DIR}/venv/bin/python ${INSTALL_DIR}/ui/main.py \
        --enable-cors-header \
        --disable-auto-launch \
        --base-directory ${BASE_DIR} \
        --temp-directory ${TEMP_DIR} \
        --output-directory ${OUTPUT_DIR} \
        --input-directory ${INPUT_DIR} \
        --user-directory ${USER_DIR} \
        --cpu \
        --listen 127.0.0.1 \
        --port 8188
fi