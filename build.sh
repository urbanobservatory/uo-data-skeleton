#!/bin/bash

if [ -z "$1" ]
  then
    echo "No instance argument supplied"
    echo "Usage: "$0" instance [docker-compose options]"
    exit 1
fi

set -o allexport
source config/$1.env
set +o allexport

# set directory of src code
if [[ -z "${CODE_BASE_DIR}" ]]; 
  then
    CODE_BASE_DIR="../uo-data-box"
fi

echo "[--] Building $1 master image..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f ${CODE_BASE_DIR}/src/apps/master/docker-compose.yml \
            build "${@:2}"

exit 0           