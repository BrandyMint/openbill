#!/usr/bin/env bash

. ./tests/init.sh && \

echo "insert into OPENBILL_ACCOUNTS  (id, category_id) values ($ACCOUNT1_UUID, $CATEGORY_UUID)" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id) values ($ACCOUNT2_UUID, $CATEGORY_UUID)" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id) values ($ACCOUNT3_UUID, $CATEGORY_UUID)" | ./tests/sql.sh && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (invoice_id, amount_value, amount_currency, from_account_id, to_account_id, key, details) values ($INVOICE_UUID, 100, 'USD', $ACCOUNT2_UUID, $ACCOUNT1_UUID, 'gid://order3', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "select paid_value from OPENBILL_INVOICES where id =  $INVOICE_UUID" '100.000000000000000000' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', $ACCOUNT2_UUID, $ACCOUNT3_UUID, 'gid://order4', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_value, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', $ACCOUNT3_UUID, $ACCOUNT1_UUID, 'gid://order5', 'test')" 'INSERT 0 1' && \

./tests/assert_result.sh "update OPENBILL_TRANSACTIONS set amount_value=1" 'ERROR:  permission denied for table openbill_transactions' && \
./tests/assert_result.sh "delete from OPENBILL_TRANSACTIONS" 'ERROR:  permission denied for table openbill_transactions'
