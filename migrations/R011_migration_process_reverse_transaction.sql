CREATE OR REPLACE FUNCTION process_reverse_transaction() RETURNS TRIGGER AS $process_transaction$
BEGIN
  IF NEW.reverse_transaction_id IS NOT NULL THEN
    PERFORM * FROM openbill_transactions
      WHERE amount_value = NEW.amount_value
        AND amount_currency = NEW.amount_currency
        AND from_account_id = NEW.to_account_id
        AND to_account_id = NEW.from_account_id
        AND id = NEW.reverse_transaction_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Not found reverse transaction with same accounts and amount (#%)', NEW.reverse_transaction_id;
    END IF;

  END IF;

  return NEW;
END

$process_transaction$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS process_reverse_transaction ON OPENBILL_TRANSACTIONS;
CREATE TRIGGER process_reverse_transaction
  AFTER INSERT ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE process_reverse_transaction();
