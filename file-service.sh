#!/bin/bash

if [ -z "$1" ]
  then
    echo "No instance argument supplied"
    echo "Usage: "$0" instance {start|stop|restart} [docker-compose options]"
    exit 1
fi

set -o allexport
source config/$1.env
set +o allexport

case "$2" in
  start)
        echo "[--] Starting $1 file service..."       
        docker-compose --project-name=${UO_INSTANCE} \
            -f shared/file/docker-compose.yml \
            up -d "${@:3}"
              

        echo " "
	;;
  stop)
        echo "[--] Stopping $1 file service..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f shared/file/docker-compose.yml \
            down "${@:3}"
              
        echo " "
	;;
  restart)
        echo "[--] Stopping $1 file service..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f shared/file/docker-compose.yml \
            restart "${@:3}"        
        
        echo " "
	;;

  *)
	echo "Usage: "$0" instance {start|stop|restart} [docker-compose options]"
	exit 1
esac

exit 0