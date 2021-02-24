#!/bin/bash

if [ -z "$1" ]
  then
    echo "No instance argument supplied"
    echo "Usage: "$0" instance {BROKERS} {start|stop|restart} [docker-compose options]"
    exit 1
fi

IFS=',' read -ra brokers <<< "$2"

if [ "$#" -lt 3 ]
  then
    echo "Insufficient arguments supplied"
    echo "Usage: "$0" instance {BROKERS} {start|stop|restart} [docker-compose options]"
    exit 1
fi

set -o allexport
source config/$1.env
set +o allexport

if [[ -z "${CODE_BASE_DIR}" ]]; 
  then
    CODE_BASE_DIR="../uo-data-box"
fi

case "$3" in
  start)

        for i in "${brokers[@]}"
        do          
          if [ "$i" = "UTMC.OpenFeeds" ]
          then
            echo "[--] Starting $1 brokerage services for $i..."
            docker-compose --project-name=${UO_INSTANCE} \
              -f ${CODE_BASE_DIR}/src/apps/broker/config/utmc/docker-compose.yml \
              up -d "${@:4}"
          else
            echo "[--] Starting $1 brokerage services for $i..."
            # Overiding broker config from command line            
            UO_BROKER_CONFIGURATION="${i}"
            docker-compose --project-name=${UO_INSTANCE} \
              -f ${CODE_BASE_DIR}/src/apps/broker/docker-compose.yml \
              up -d "${@:4}"
          fi
        done              

        echo " "
	;;
  stop)
        echo "[WARNING] This is a potentially destructive action."
        echo "          Data will be lost while AMQP services are down."
        echo ""
        echo "Will continue in 5 seconds..."
        sleep 5
        echo ""
        
        for i in "${brokers[@]}"
        do          
          if [ "$i" = "UTMC.OpenFeeds" ]
          then
            echo "[--] Stopping $1 brokerage services for $i..."
            docker-compose --project-name=${UO_INSTANCE} \
              -f ${CODE_BASE_DIR}/src/apps/broker/config/utmc/docker-compose.yml \
              down "${@:4}"
          else
            echo "[--] Stopping $1 brokerage services for $i..."
            # Overiding broker config from command line            
            UO_BROKER_CONFIGURATION="${i}"
            docker-compose --project-name=${UO_INSTANCE} \
              -f ${CODE_BASE_DIR}/src/apps/broker/docker-compose.yml \
              down "${@:4}"
          fi
        done       

        echo " "
	;;
  restart)
        for i in "${brokers[@]}"
        do          
          if [ "$i" = "UTMC.OpenFeeds" ]
          then
            echo "[--] Restarting $1 brokerage services for $i..."
            docker-compose --project-name=${UO_INSTANCE} \
              -f ${CODE_BASE_DIR}/src/apps/broker/config/utmc/docker-compose.yml \
              restart "${@:4}"
          else
            echo "[--] Restarting $1 brokerage services for $i..."
            # Overiding broker config from command line            
            UO_BROKER_CONFIGURATION="${i}"
            docker-compose --project-name=${UO_INSTANCE} \
              -f ${CODE_BASE_DIR}/src/apps/broker/docker-compose.yml \
              restart "${@:4}"
          fi
        done       
        
        echo " "
	;;

  *)
  echo "Invalid arguments supplied"
	echo "Usage: "$0" instance {BROKERS} {start|stop|restart} [docker-compose options]"
	exit 1
esac

exit 0