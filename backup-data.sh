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
        echo "[--] Starting database backups for ${UO_INSTANCE}..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f shared/backups/docker-compose.yml \
            up -d "${@:3}"
              

        echo " "
	;;
  stop)
        echo "[--] Stopping database backups for ${UO_INSTANCE}..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f shared/backups/docker-compose.yml \
            down "${@:3}"
              
        echo " "
	;;
  restart)
        echo "[--] Restarting database backups for ${UO_INSTANCE}..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f shared/backups/docker-compose.yml \
            restart "${@:3}"        
        
        echo " "
	;;

  *)
	echo "Usage: "$0" instance {start|stop|restart} [docker-compose options]"
	exit 1
esac

exit 0