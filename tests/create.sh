#!/usr/bin/env bash

test -z "$PGDATABASE" && PGDATABASE='openbill_test'

LOGS_DIR='./log/'; test -d $LOGS_DIR || mkdir $LOGS_DIR

LOGFILE="$LOGS_DIR/create.log"

message="Recreate database ${PGDATABASE}"

echo $message
echo $message > $LOGFILE

dropdb --if-exists $PGDATABASE >> $LOGFILE && \
  createdb $PGDATABASE >> $LOGFILE && \
  psql -1 $PGDATABASE < ./sql/0_db.sql >> $LOGFILE && \
  cat ./sql/?_trigger*.sql | psql -1 $PGDATABASE >> $LOGFILE && \
  cat ./sql/?_migration*.sql | psql -1 $PGDATABASE >> $LOGFILE && \
  echo "SET lc_messages TO 'en_US.UTF-8';" | psql -1 $PGDATABASE >> $LOGFILE
