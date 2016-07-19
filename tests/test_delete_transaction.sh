#!/usr/bin/env sh

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

./tests/assert_result.sh "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test')" 'INSERT 0 1' && \

./tests/assert_value.sh "select amount_cents from OPENBILL_ACCOUNTS  where id=$ACCOUNT1_UUID" '-100' && \
./tests/assert_value.sh "select amount_cents from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '100' && \

./tests/assert_result.sh "delete from OPENBILL_TRANSACTIONS" 'DELETE 1' && \

./tests/assert_value.sh "select amount_cents from OPENBILL_ACCOUNTS  where id=$ACCOUNT1_UUID" '0' && \
./tests/assert_value.sh "select amount_cents from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '0'
