#!/bin/bash

if [[ -z "${UO_INSTANCE}" ]]; then
	echo "Must set UO_INSTANCE variable."
	exit 1
fi


# Directories required
mkdir -p "/app/output/${UO_INSTANCE}"

function sqlCommand {
	PGPASSWORD="${POSTGRES_PASSWORD}" psql -h"${UO_DB_HOST}" -p"${UO_DB_PORT}" -U"${POSTGRES_USER}" "${POSTGRES_DB}" -A -t -c "$1" 2> /dev/null
}

function dumpToCSV() {

	PGPASSWORD="${POSTGRES_PASSWORD}" psql -h"${UO_DB_HOST}" -p"${UO_DB_PORT}" -U"${POSTGRES_USER}" "${POSTGRES_DB}" -c "$1" 2> /dev/null

	if [[ "$?" -gt "0" ]]; then
		echo "An error occured while producing CSV for $1."
		return
	fi
}

echo "Filtering database ${POSTGRES_DB} on ${UO_DB_HOST}:${UO_DB_PORT}..."

start=$(date -d ${FILTER_START_DATE} +%Y%m%d) || exit -1
end=$(date -d ${FILTER_END_DATE} +%Y%m%d) || exit -1
FILTER_TABLES=($FILTER_TABLES)

while [[ $start -le $end ]]
do
    starttime=$(date -d $start +%FT%TZ)
    endtime=$(date -d "$start 23:59:59" +%FT%TZ)
	for table in "${FILTER_TABLES[@]}"
	do
		CMD=$(echo $(cat << EOM
			\COPY
			(SELECT t.timeseries_id, data."time", data."value"
			FROM $table data
			INNER JOIN uo_timeseries t
			ON t.timeseries_num = data.timeseries_num
			WHERE "time" >= '${starttime}'
			AND "time" <= '${endtime}'
			AND data.timeseries_num IN
			(
			SELECT t.timeseries_num
			FROM uo_licence l
			INNER JOIN uo_provider p 
				ON p.licence_id = l.licence_id
			INNER JOIN uo_feed f
				ON f.provider_id = p.provider_id
			INNER JOIN uo_timeseries t
				ON t.feed_id = f.feed_id
			WHERE (l.description->'open') = 'true'
			)) TO '/app/output/${UO_INSTANCE}/${table}_${start}.csv' DELIMITER ',' CSV HEADER;
EOM
		))
		echo "Processing ${table} from ${starttime} to ${endtime}"
		dumpToCSV "$CMD"
		echo "Compressing ${table}_${start}.csv"
		tar -czf /app/output/${UO_INSTANCE}/${table}_${start}.tar.gz /app/output/${UO_INSTANCE}/${table}_${start}.csv --remove-files
		sleep 2m # back off for 2 minutes
	done
    start=$(date -d "$start + 1 day" +"%Y%m%d")
done