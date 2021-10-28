#!/usr/bin/env sh

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

echo "insert into OPENBILL_TRANSACTIONS (amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test')" | ./tests/sql.sh && \

./tests/assert_result_include.sh "INSERT INTO OPENBILL_HOLDS (account_id, amount_value, amount_currency, remote_idempotency_key, details) VALUES ( $ACCOUNT2_UUID, '60', 'USD', 'a57e58dd76b6e8d6f4a1c94a6a8ce0cb', '-')" 'INSERT 0 1' && \
./tests/assert_value.sh "select amount_value from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '40.000000000000000000' && \
./tests/assert_value.sh "select hold_value from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '60.000000000000000000' && \
./tests/assert_result_include.sh "INSERT INTO OPENBILL_HOLDS (account_id, amount_value, amount_currency, remote_idempotency_key, details) VALUES ( $ACCOUNT2_UUID, '100', 'USD', 'a57e58dd76b6e8d6', '-')" 'ERROR:  It is impossible to block the amount more than is on the account' && \
./tests/assert_result_include.sh "INSERT INTO OPENBILL_HOLDS (account_id, amount_value, amount_currency, remote_idempotency_key, hold_key, details) VALUES ( $ACCOUNT2_UUID, '-40', 'USD', 'e9698c771c8f4d7768734b66dfada659', 'a57e58dd76b6e8d6f4a1c94a6a8ce0cb', '-')" 'INSERT 0 1' && \
./tests/assert_value.sh "select amount_value from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '80.000000000000000000' && \
./tests/assert_value.sh "select hold_value from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '20.000000000000000000' && \
./tests/assert_result_include.sh "INSERT INTO OPENBILL_HOLDS (account_id, amount_value, amount_currency, remote_idempotency_key, hold_key, details) VALUES ( $ACCOUNT2_UUID, '-40', 'USD', 'e9698c771c8f4d77', 'a57e58dd76b6e8d6f4a1c94a6a8ce0cb', '-')" 'ERROR:  It is impossible to unblock the amount more than is on the account'
