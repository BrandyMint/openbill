#!/usr/bin/env sh

echo "Можно обновлять детали"

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

export PGUSER=openbill-test

./tests/assert_result_include.sh "delete from OPENBILL_ACCOUNTS" 'Cannot delete account' && \

# TODO: Пока эти тесты еще не проходят

# Это можно
./tests/assert_result_include.sh "update OPENBILL_ACCOUNTS set details='some' where id=$ACCOUNT1_UUID" 'UPDATE 1' && \

# Нельзя этому случиться"update OPENBILL_ACCOUNTS set amount_value=123 where id=$ACCOUNT1_UUID"
psql -d openbill_test -c "update OPENBILL_ACCOUNTS set amount_value=123 where id=$ACCOUNT1_UUID"
./tests/assert_result_include.sh "update OPENBILL_ACCOUNTS set amount_value=123 where id=$ACCOUNT1_UUID" 'ERROR:  permission denied for table openbill_accounts' && \
./tests/assert_result_include.sh "update OPENBILL_ACCOUNTS set created_at=current_date where id=$ACCOUNT1_UUID" 'ERROR:  permission denied for table openbill_accounts'
