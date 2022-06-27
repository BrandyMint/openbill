#!/usr/bin/env bash

. ./tests/init.sh && \

./tests/assert_result_include.sh "insert into OPENBILL_ACCOUNTS  (id, category_id, amount_value) values ($ACCOUNT1_UUID, $CATEGORY_UUID, 100)" 'ERROR:  When creating an account, the balance must be equal to 0' && \

./tests/assert_result_include.sh "insert into OPENBILL_ACCOUNTS  (id, category_id,hold_value) values ($ACCOUNT1_UUID, $CATEGORY_UUID, 100)" 'ERROR:  When creating an account, the balance must be equal to 0' && \

./tests/assert_result_include.sh "insert into OPENBILL_ACCOUNTS  (id, category_id, amount_value, hold_value) values ($ACCOUNT1_UUID, $CATEGORY_UUID, 100, 100)" 'ERROR:  When creating an account, the balance must be equal to 0' && \

./tests/assert_result_include.sh "insert into OPENBILL_ACCOUNTS  (id, category_id, amount_value) values ($ACCOUNT1_UUID, $CATEGORY_UUID, 0)" 'INSERT 0 1'
