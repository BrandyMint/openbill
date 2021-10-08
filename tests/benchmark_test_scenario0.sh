#!/usr/bin/env bash

if [ "$#" -ne 2 -o "$1" == "help" ]; then
  echo "use: bash ./tests/benchmark_test_scenario0.sh <uuid1> <uuid2>"
  echo "You can use evniroments:"
  echo "  - PGHOST - postgres host (default local socket)"
  echo "  - PGUSER - postgres user (default Linix user)"
  echo "  - PGPASSWORD - postgres password (default empty)"
  echo "  - PGDATABASE - postgres database (default openbill_test)"
  exit 1
fi

test -z "$PGDATABASE" && PGDATABASE='openbill_test'
fails=0
green="\033[32m"
red="\033[31m"
reset="\033[0m"


sum1=`echo $((100 + $RANDOM % 9900))`
holdid=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

if ./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details) values ($sum1, 'USD', '$1', '$2', md5(random()::text), 'pid: #$$, transaction01')" 'INSERT 0 1' && \
    ./tests/assert_result_include.sh "INSERT INTO OPENBILL_LOCKS (username, account_id, amount_cents, amount_currency, key, details) VALUES (user, '$2', $sum1/2, 'USD', '$holdid', 'pid: #$$. hold')" 'INSERT 0 1' && \
    ./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details) values ($sum1 - $sum1/2, 'USD', '$2', '$1', md5(random()::text), 'pid: #$$, transaction02')" 'INSERT 0 1' && \
    ./tests/assert_result_include.sh "INSERT INTO OPENBILL_LOCKS (username, account_id, amount_cents, amount_currency, key, lock_key, details) VALUES (user, '$2', -$sum1/2, 'USD', md5(random()::text), '$holdid', 'pid: #$$. unhold')" 'INSERT 0 1' && \
    ./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details) values ($sum1/2, 'USD', '$2', '$1', md5(random()::text), 'pid: #$$, transaction03')" 'INSERT 0 1' && \
    echo "TEST PASSED" && ./tests/assert_balance.sh && echo "BALANCE PASSED"; then
  echo -e "${green}CONTROL PASSED."
  echo -e $reset
else
  fails=`echo 1 + $fails | bc`
  echo -e "${red}FAIL! ($fails)"
  echo -e $reset
fi
