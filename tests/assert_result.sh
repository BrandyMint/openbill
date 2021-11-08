#!/usr/bin/env bash

query="$1"
value="$2"

#echo "SET lc_messages TO 'en_US.UTF-8';" > .query.tmp
#echo $query >> .query.tmp
echo -e "\tassert_result '$query'"
echo -e "\t\tMust be: '$value' "
RES=`echo "$query" | psql -q --no-align -t 2>&1`

if [ $? = 0 ]; then
  if [ "$RES" = "$value" ]; then
    echo 'ok'
  else
    echo -e "\nFAIL! Result is wrong: '$RES'"
    exit 1
  fi
else
  echo "Error executing $query"
  exit $?
fi
