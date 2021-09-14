#!/usr/bin/env sh

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

echo "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test')" | ./tests/sql.sh && \

./tests/assert_result_include.sh "INSERT INTO OPENBILL_LOCKS (username, account_id, amount_cents, amount_currency, key, details) VALUES (user, $ACCOUNT2_UUID, '10', 'USD', 'a57e58dd76b6e8d6f4a1c94a6a8ce0cb', '-')" 'INSERT 0 1' && \
./tests/assert_value.sh "select amount_cents from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '90' && \
./tests/assert_value.sh "select locked_cents from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '10'
