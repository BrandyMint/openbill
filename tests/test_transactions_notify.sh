#!/usr/bin/env sh

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

TRANSACTION_UUID="1"

./tests/assert_result_include.sh "listen OPENBILL_TRANSACTIONS; insert into OPENBILL_TRANSACTIONS (id, amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values ('$TRANSACTION_UUID', 100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test')" "Asynchronous notification \"openbill_transactions\" with payload \"$TRANSACTION_UUID\" received from server"
