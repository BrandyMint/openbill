CREATE OR REPLACE FUNCTION openbill_transaction_delete() RETURNS TRIGGER AS $process_transaction$
BEGIN
  -- установить last_transaction_id, counts и _at
  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents - OLD.amount_cents, last_transaction_id = NULL, last_transaction_at = CURRENT_TIMESTAMP, transactions_count = transactions_count - 1 WHERE id = OLD.to_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents + OLD.amount_cents, last_transaction_id = NULL, last_transaction_at = CURRENT_TIMESTAMP, transactions_count = transactions_count - 1 WHERE id = OLD.from_account_id;

  return OLD;
END

$process_transaction$ LANGUAGE plpgsql;

CREATE TRIGGER openbill_transaction_delete
  BEFORE DELETE ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE openbill_transaction_delete();
