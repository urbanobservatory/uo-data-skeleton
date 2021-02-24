#!/bin/bash


# funtion for creating rabbitmq password hash
function password_hash()
{
    SALT=$(od -A n -t x -N 4 /dev/urandom)
    PASS=$SALT$(echo -n $1 | xxd -ps | tr -d '\n' | tr -d ' ')
    PASS=$(echo -n $PASS | xxd -r -p | sha256sum | head -c 128)
    PASS=$(echo -n $SALT$PASS | xxd -r -p | base64 | tr -d '\n')
    return $PASS
}

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

if [[ -z "${RABBITMQ_ADMIN_PASSWORD}" || -z "${UO_MASTER_BROKER_AMQP_PASSWORD}" || -z ${UO_BROKER_AMQP_PASSWORD} || -z ${UO_STREAM_AMQP_PASSWORD} ]]; then
  echo "Some AMQP password variables are not set"
  exit 1
fi

# create definitions file for rabbitmq
sed "s/RABBITMQ_ADMIN_PASSWORD/$password_hash ${RABBITMQ_ADMIN_PASSWORD}/g;s/UO_MASTER_BROKER_AMQP_PASSWORD/$password_hash ${UO_MASTER_BROKER_AMQP_PASSWORD}/g;s/UO_BROKER_AMQP_PASSWORD/$password_hash ${UO_BROKER_AMQP_PASSWORD}/g;s/UO_STREAM_AMQP_PASSWORD/$password_hash ${UO_STREAM_AMQP_PASSWORD}/g;s/UO_HOST/${UO_HOST}/g" config/definitions.json.template > ${CODE_BASE_DIR}/src/apps/master/config/rabbitmq/definitions.json

case "$2" in
  start)
        echo "[--] Starting $1 master queue services..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f ${CODE_BASE_DIR}/src/apps/master/config/rabbitmq/docker-compose.yml \
            up -d "${@:3}"

        echo " "
	;;
  stop)
        echo "[WARNING] This is a potentially destructive action."
        echo "          Data will be lost while AMQP services are down."
        echo ""
        echo "Will continue in 5 seconds..."
        sleep 5
        echo ""

        echo "[--] Starting $1 master queue services..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f ${CODE_BASE_DIR}/src/apps/master/config/rabbitmq/docker-compose.yml \
            down "${@:3}"

        echo " "
	;;
  restart)
        echo "[--] Restarting $1 master queue services..."
        docker-compose --project-name=${UO_INSTANCE} \
            -f ${CODE_BASE_DIR}/src/apps/master/config/rabbitmq/docker-compose.yml \
            restart "${@:3}"
        
        echo " "
	;;

  *)
	echo "Usage: "$0" instance {start|stop|restart} [docker-compose options]"
	exit 1
esac

exit 0