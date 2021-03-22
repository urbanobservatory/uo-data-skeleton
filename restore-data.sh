#!/bin/bash

if [ -z "$1" ]
  then
    echo "No instance argument supplied"
    echo "Usage: "$0" instance {tables|data|temp} filespath"
    exit 1
fi

if [ "$#" -lt 3 ]
  then
    echo "Insufficient arguments supplied"
    echo "Usage: "$0" instance {tables|data|temp} filespath"
    exit 1
fi

NOW=$( date +"%FT%H%M%S" )
# TODO: check if the best way to get files (needs /* ATM)
FOLDER=${*:3}
LOGFILE="restore-$1-$2.$NOW.log"

set -o allexport
source config/$1.env
set +o allexport


case "$2" in
  tables)
        echo "[WARNING] This is a potentially destructive action."
        echo "          Data consistency may be harmed if run on non empty database."
        echo ""
        echo "Will continue in 5 seconds..."
        sleep 5
        echo ""

        echo "[--] Restoring tables for $1..."
        # get correct table restore order
        for file in $(cat shared/backups/restore-order.txt); do
          if [ "$file" = "spatial_ref_sys.sql.gz" ]; then
            filepath="${FOLDER}/public.${file}"
          else
            filepath="${FOLDER}/public.${TABLE_PREFIX}${file}"
          fi  
          # echo "Processing $filepath..."
          if [ -f "$filepath" ]; then
            echo "Processing $filepath..."
            gunzip -c $filepath | PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${UO_DATA_HOST}" -p "${POSTGRES_PORT}" -U ${POSTGRES_USER} ${POSTGRES_DB}
            # Get error messages from pipe and command        
            retval_gunzip="${PIPESTATUS[0]}" retval_psql="${PIPESTATUS[1]}" retval_final=$?
            if [[ $retval_gunzip -eq 0 && $retval_psql -eq 0 && $retval_final -eq 0 ]]; then
              echo "Command succeeded for $filepath"
            else
              echo "Command failed for $filepath"
              echo "$retval_gunzip,$retval_psql,$retval_final,$filepath" >> $LOGFILE
            fi 
          fi
        done
        echo "."
	;;
  data)
        echo "[WARNING] This is a potentially destructive action."
        echo "          Data consistency may be harmed if run on non empty database."
        echo ""
        echo "Will continue in 5 seconds..."
        sleep 5
        echo ""

        echo "[--] Restoring data for $1..."
        for file in $FOLDER; do  
          # echo "Processing $file..."
          if [ -f "$file" ]; then
            echo "Processing $file..."
            gunzip -c $file | PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${UO_DATA_HOST}" -p "${POSTGRES_PORT}" -U ${POSTGRES_USER} ${POSTGRES_DB}
            # Get error messages from pipe and command            
            retval_gunzip="${PIPESTATUS[0]}" retval_psql="${PIPESTATUS[1]}" retval_final=$?
            if [[ $retval_gunzip -eq 0 && $retval_psql -eq 0 && $retval_final -eq 0 ]]; then
              echo "Command succeeded for $file"
            else
              echo "Command failed for $file"
              echo "$retval_gunzip,$retval_psql,$retval_final,$file" >> $LOGFILE
            fi
          fi
        done
        echo "."
	;;
  temp)
        echo "[WARNING] This is a potentially destructive action."
        echo "          Data consistency may be harmed if run on non empty database."
        echo ""
        echo "Will continue in 5 seconds..."
        sleep 5
        echo ""

        echo "[--] Restoring data into _TEMP_ tables for $1..."
        for file in $FOLDER; do  
          # echo "Processing $file..."
          if [ -f "$file" ]; then
            echo "Processing $file..."
            # FIXME: needs better way to get tablename
            filename="$(basename -- ${file})"            
            tablename=$(echo ${filename} | awk -F"_" '{print $1"_"$2"_"$3"_"$4}')
            #echo "CREATE TABLE ${tablename}_temp AS (SELECT * FROM ${tablename}) WITH NO data;"
            ## CREATE temp table
            PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${UO_DATA_HOST}" -p "${POSTGRES_PORT}" -U ${POSTGRES_USER} ${POSTGRES_DB} -c "CREATE TABLE IF NOT EXISTS ${tablename}_temp AS (SELECT * FROM ${tablename}) WITH NO data;"
            #zcat -c $file | sed -e "s/${tablename}/${tablename}_temp/g" | head -n 30
            ## INSERT data into temp table
            gunzip -c $file | sed -e "s/${tablename}/${tablename}_temp/g" | PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${UO_DATA_HOST}" -p "${POSTGRES_PORT}" -U ${POSTGRES_USER} ${POSTGRES_DB}
            PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${UO_DATA_HOST}" -p "${POSTGRES_PORT}" -U ${POSTGRES_USER} ${POSTGRES_DB} -c "INSERT INTO ${tablename} SELECT * FROM ${tablename}_temp ON CONFLICT DO NOTHING;"
            ## DROP temp table
            PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${UO_DATA_HOST}" -p "${POSTGRES_PORT}" -U ${POSTGRES_USER} ${POSTGRES_DB} -c "DROP TABLE IF EXISTS ${tablename}_temp;"
            # Get error messages from pipe and command            
            retval_gunzip="${PIPESTATUS[0]}" retval_psql="${PIPESTATUS[1]}" retval_final=$?
            if [[ $retval_gunzip -eq 0 && $retval_psql -eq 0 && $retval_final -eq 0 ]]; then
              echo "Command succeeded for $file"
            else
              echo "Command failed for $file"
              echo "$retval_gunzip,$retval_psql,$retval_final,$file" >> $LOGFILE
            fi
          fi
        done
        echo " "
	;;

  *)
	echo "Usage: "$0" instance {tables|data|temp} filespath"
	exit 1
esac

exit 0