#!/usr/bin/bash

if [[ -z $VIRTUAL_ENV_DIR ]]
then
  VIRTUAL_ENV_DIR=/home/comfy/.venv
fi
if [[ -z $BASE_DIR ]]
then
  BASE_DIR=/home/comfy/ComfyUI/
fi
for dir in ${BASE_DIR}/custom_nodes/*
do
  if [[ -f ${dir}/requirements.txt ]] && [[ $dir != "__pycache__" ]]
  then 
    ${VIRTUAL_ENV_DIR}/bin/pip install -r ${dir}/requirements.txt
  fi
done
