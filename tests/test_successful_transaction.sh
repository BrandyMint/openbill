#!/usr/bin/env sh

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test')" 'INSERT 0 1' && \

./tests/assert_value.sh "select amount_value from OPENBILL_ACCOUNTS  where id=$ACCOUNT1_UUID" '-100.000000000000000000' && \
./tests/assert_value.sh "select amount_value from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '100.000000000000000000' && \
./tests/assert_value.sh 'select count(*) from OPENBILL_TRANSACTIONS ' '1' &&\
# testing hold
./tests/assert_result_include.sh "update OPENBILL_ACCOUNTS set locked_at='01.01.2021 00:00:00' WHERE id = $ACCOUNT2_UUID" 'UPDATE 1' && \
./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (100, 'USD', $ACCOUNT2_UUID, $ACCOUNT1_UUID, 'gid://order2', 'test')" "ERROR:  Account (from #$ACCOUNT1_UUID) is hold from 2021-01-01 00:00:00"
