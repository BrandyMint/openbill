#!/usr/bin/env bash

query="$1"
value="$2"

echo -n -e "\tExecute '$query' contains '$value': "
RES=`echo "$query" | psql --no-align -t 2>&1`

if [ $? = 0 ]; then
  if [[ "$RES" =~ "$value" ]]; then
    echo 'ok'
  else
    echo "FAIL! Result '$RES' does not contains '$value'"
    exit 1
  fi
else
  echo "Error executing $query"
  exit 1
fi
