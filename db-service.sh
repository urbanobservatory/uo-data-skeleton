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

if [[ -z "${CODE_BASE_DIR}" ]]; 
  then
    CODE_BASE_DIR="../uo-data-box"
fi

case "$2" in
  start)
        echo "[--] Starting $1 master database services..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f ${CODE_BASE_DIR}/src/apps/master/config/timescaledb/docker-compose.yml \
            up -d "${@:3}"

        echo " "
	;;
  stop)
        echo "[WARNING] This is a potentially destructive action."
        echo "          Data could be lost while database services are down."
        echo ""
        echo "Will continue in 5 seconds..."
        sleep 5
        echo ""

        echo "[--] Stopping $1 master database services..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f ${CODE_BASE_DIR}/src/apps/master/config/timescaledb/docker-compose.yml \
            down "${@:3}"
            
        echo " "
	;;
  restart)
        echo "[--] Restarting $1 master database services..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f ${CODE_BASE_DIR}/src/apps/master/config/timescaledb/docker-compose.yml \
            restart "${@:3}"
        
        echo " "
	;;

  *)
	echo "Usage: "$0" instance {start|stop|restart} [docker-compose options]"
	exit 1
esac

exit 0