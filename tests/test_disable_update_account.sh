#!/usr/bin/env sh

echo "Можно обновлять детали"

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

./tests/assert_result_include.sh "delete from OPENBILL_ACCOUNTS" 'Cannot delete account' && \

# TODO: Пока эти тесты еще не проходят

# Это можно
./tests/assert_result.sh "update OPENBILL_ACCOUNTS set details='some' where id=$ACCOUNT1_UUID" 'UPDATE 1' && \

# Нельзя этому случиться
./tests/assert_result_include.sh "update OPENBILL_ACCOUNTS set amount_cents=123 where id=$ACCOUNT1_UUID" 'Cannot directly update amount_cents and timestamps of account' && \
./tests/assert_result_include.sh "update OPENBILL_ACCOUNTS set created_at=current_date where id=$ACCOUNT1_UUID" 'Cannot directly update amount_cents and timestamps of account'
