#!/bin/bash

if [ -z "$1" ]
  then
    echo "No instance argument supplied"
    echo "Usage: "$0" instance start_date end_date storage_table [storage_table storage_table]"
    exit 1
fi

set -o allexport
source config/${1}.env
set +o allexport

docker-compose --project-name=${UO_INSTANCE} \
    -f shared/filter/docker-compose.yml \
    run \
    -e FILTER_START_DATE="${2}" \
    -e FILTER_END_DATE="${3}" \
    -e FILTER_TABLES="${*:4}" \
    -T \
    --rm \
    db-filter