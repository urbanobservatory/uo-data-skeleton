#!/bin/bash

if [ -z "$1" ]
  then
    echo "No instance argument supplied"
    echo "Usage: "$0" instance {data|web}"
    exit 1
fi

set -o allexport
source config/$1.env
set +o allexport

if [[ -z "${CODE_BASE_DIR}" ]]; 
  then
    CODE_BASE_DIR="../uo-data-box"
fi

case "$2" in
  data)
        echo "[--] Following $1 master data consumer service..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f ${CODE_BASE_DIR}/src/apps/master/docker-compose.yml \
            logs \
            --tail=50 \
            -f

        echo " "
	;;
  web)
        echo "[--] Following $1 API and stream services..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f ${CODE_BASE_DIR}/src/apps/web/docker-compose.yml \
            logs \
            --tail=50 \
            -f      

        echo " "
	;;

  *)
	echo "Usage: "$0" instance {data|web}"
	exit 1
esac

exit 0