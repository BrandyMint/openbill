#!/usr/bin/env bash

. ./tests/init.sh && \

echo "insert into OPENBILL_ACCOUNTS  (id, category_id) values ($ACCOUNT1_UUID, $CATEGORY_UUID)" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id) values ($ACCOUNT2_UUID, $CATEGORY_UUID)" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id) values ($ACCOUNT3_UUID, $CATEGORY_UUID)" | ./tests/sql.sh && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values ( 100, 'USD', $ACCOUNT2_UUID, $ACCOUNT1_UUID, 'gid://order3', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (100, 'USD', $ACCOUNT2_UUID, $ACCOUNT3_UUID, 'gid://order4', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (100, 'USD', $ACCOUNT3_UUID, $ACCOUNT1_UUID, 'gid://order5', 'test')" 'INSERT 0 1' && \

./tests/assert_result.sh "update OPENBILL_TRANSACTIONS set amount_value=1" 'ERROR:  permission denied for table openbill_transactions' && \
./tests/assert_result.sh "delete from OPENBILL_TRANSACTIONS" 'ERROR:  permission denied for table openbill_transactions'
