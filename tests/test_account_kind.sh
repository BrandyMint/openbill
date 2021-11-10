#!/usr/bin/env bash

. ./tests/init.sh && \

echo "insert into OPENBILL_ACCOUNTS  (id, category_id, kind) values ($ACCOUNT1_UUID, $CATEGORY_UUID, 'positive')" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id, kind) values ($ACCOUNT2_UUID, $CATEGORY_UUID, 'negative')" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id, kind) values ($ACCOUNT3_UUID, $CATEGORY_UUID, 'any')" | ./tests/sql.sh && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test')" 'ERROR:  new row for relation "openbill_accounts" violates check constraint "openbill_accounts_kind' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (100, 'USD', $ACCOUNT2_UUID, $ACCOUNT1_UUID, 'gid://order2', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (200, 'USD', $ACCOUNT2_UUID, $ACCOUNT3_UUID, 'gid://order3', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (400, 'USD', $ACCOUNT3_UUID, $ACCOUNT1_UUID, 'gid://order4', 'test')" 'INSERT 0 1'
