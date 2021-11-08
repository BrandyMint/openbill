echo "insert into OPENBILL_ACCOUNTS  (id, category_id) values ($ACCOUNT1_UUID, $CATEGORY_UUID)" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (id, category_id) values ($ACCOUNT2_UUID, $CATEGORY_UUID)" | ./tests/sql.sh
