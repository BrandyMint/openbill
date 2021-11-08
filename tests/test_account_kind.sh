#!/usr/bin/env bash

. ./tests/init.sh && \

echo "insert into OPENBILL_ACCOUNTS  (id, category_id, key, kind) values ($ACCOUNT1_UUID, $CATEGORY_UUID, 'gid://owner1', 'positive')" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id, key, kind) values ($ACCOUNT2_UUID, $CATEGORY_UUID, 'gid://owner2', 'negative')" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id, key, kind) values ($ACCOUNT3_UUID, $CATEGORY_UUID, 'gid://owner3', 'any')" | ./tests/sql.sh && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order4', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', $ACCOUNT2_UUID, $ACCOUNT1_UUID, 'gid://order5', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT3_UUID, 'gid://order5', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, key, details) values (200, 'USD', $ACCOUNT3_UUID, $ACCOUNT2_UUID, 'gid://order5', 'test')" 'INSERT 0 1'
