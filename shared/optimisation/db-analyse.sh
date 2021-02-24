#!/bin/bash

export PGPASSWORD="${UO_DB_PASS}"

INDEX_DATA=$(psql \
  -A -t \
  -U"${UO_DB_USER}" \
  -h"${UO_DB_HOST}" \
  -p"${UO_DB_PORT}" \
  --pset footer \
  "${UO_DB_NAME}" << EndOfSql
select tc.table_schema, tc.table_name, tc.constraint_name
from information_schema.table_constraints tc
where tc.constraint_type = 'PRIMARY KEY'
  and tc.table_schema = '_timescaledb_internal'
order by tc.table_schema,
         tc.table_name;
EndOfSql
)

while read -r INDEX_ROW; do
  IFS='|' read -ra INDEX_ARY <<< "${INDEX_ROW}"
  TBL_SCHEMA="${INDEX_ARY[0]}"
  TBL_TABLE="${INDEX_ARY[1]}"
  TBL_INDEX="${INDEX_ARY[2]}"
  SQL_CLUSTER='ANALYSE "'${TBL_SCHEMA}'"."'${TBL_TABLE}'";'
  echo "${TBL_TABLE}"
  echo "  "`psql \
    -A -t \
    -U"${UO_DB_USER}" \
    -h"${UO_DB_HOST}" \
    -p"${UO_DB_PORT}" \
    -c "${SQL_CLUSTER}" \
    "${UO_DB_NAME}"`
done <<< "${INDEX_DATA}"
