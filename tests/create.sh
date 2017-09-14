#!/usr/bin/env bash

test -z "$PGDATABASE" && PGDATABASE='openbill_test'
PGUSER=postgres

TESTUSER=openbill-test

LOGS_DIR='./log/'; test -d $LOGS_DIR || mkdir $LOGS_DIR

LOGFILE="$LOGS_DIR/create.log"

message="Recreate database ${PGDATABASE}"

echo $message
echo $message > $LOGFILE

dropuser --if-exists $TESTUSER && createuser $TESTUSER && \
dropdb --if-exists $PGDATABASE >> $LOGFILE &&  createdb $PGDATABASE >> $LOGFILE && \
  psql -1 $PGDATABASE < ./sql/0_*.sql >> $LOGFILE && \
  cat ./sql/?_trigger*.sql | psql -1 $PGDATABASE >> $LOGFILE && \
  cat ./sql/?_migration*.sql | psql -1 $PGDATABASE >> $LOGFILE
