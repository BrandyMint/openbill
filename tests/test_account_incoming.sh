#!/usr/bin/env bash

. ./tests/init.sh && \

echo "insert into OPENBILL_ACCOUNTS  (id, category_id, key) values ($ACCOUNT1_UUID, $CATEGORY_UUID, 'gid://owner1')" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id, key) values ($ACCOUNT2_UUID, $CATEGORY_UUID, 'gid://owner2')" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id, key) values ($ACCOUNT3_UUID, $CATEGORY_UUID, 'gid://owner3')" | ./tests/sql.sh && \

./tests/assert_result_include.sh "insert into OPENBILL_INVOICES  (id, number, destination_account_id, title, amount_cents) values ($INVOICE_UUID, 'first', $ACCOUNT1_UUID, 'test', 10000)" 'INSERT 0 1' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (invoice_id, amount_cents, amount_currency, from_account_id, to_account_id, key, details) values ($INVOICE_UUID, 100, 'USD', $ACCOUNT2_UUID, $ACCOUNT1_UUID, 'gid://order3', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "select paid_cents from OPENBILL_INVOICES where id =  $INVOICE_UUID" '100' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_cents, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', $ACCOUNT2_UUID, $ACCOUNT3_UUID, 'gid://order4', 'test')" 'INSERT 0 1' && \

./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS ( amount_cents, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', $ACCOUNT3_UUID, $ACCOUNT1_UUID, 'gid://order5', 'test')" 'INSERT 0 1' && \

./tests/assert_result.sh "update OPENBILL_TRANSACTIONS set amount_cents=1" 'ERROR:  permission denied for table openbill_transactions' && \
./tests/assert_result.sh "delete from OPENBILL_TRANSACTIONS" 'ERROR:  permission denied for table openbill_transactions'
