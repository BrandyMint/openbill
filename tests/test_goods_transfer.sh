#!/usr/bin/env bash

export GOOD1_UUID="'12832d8d-43f5-499b-82a1-100000000006'"

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

./tests/assert_result.sh "insert into OPENBILL_GOODS (id, title, unit) values ($GOOD1_UUID, 'Boxes', 'boxes');" "INSERT 0 1" && \
./tests/assert_result.sh "insert into OPENBILL_GOODS (title, unit) values ('Bottles', 'Bottles');" "INSERT 0 1" && \

./tests/assert_result.sh "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details, good_id, good_unit, good_value) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test', $GOOD1_UUID, 'boxes', 12.4);" "INSERT 0 1" && \

./tests/assert_value.sh "select account_id, good_id, value from OPENBILL_GOODS_AVAILABILITIES" "12832d8d-43f5-499b-82a1-000000000001|12832d8d-43f5-499b-82a1-100000000006|-12.4
12832d8d-43f5-499b-82a1-000000000002|12832d8d-43f5-499b-82a1-100000000006|12.4"
