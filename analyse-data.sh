#!/bin/bash

if [ -z "$1" ]
  then
    echo "No instance argument supplied"
    echo "Usage: "$0" instance"
    exit 1
fi

set -o allexport
source config/$1.env
set +o allexport

SCRIPTDIR="$( cd "$(dirname "$0")" ; pwd -P )"

echo "[--] Starting database analyse..."
"${SCRIPTDIR}/shared/optimisation/db-analyse.sh"
