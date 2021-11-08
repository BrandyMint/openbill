CREATE OR REPLACE FUNCTION openbill_transaction_update() RETURNS TRIGGER  AS $process_transaction$
BEGIN

  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value - OLD.amount_value, transactions_count = transactions_count - 1 WHERE id = OLD.to_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value + NEW.amount_value, transactions_count = transactions_count + 1 WHERE id = NEW.to_account_id;

  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value + OLD.amount_value, transactions_count = transactions_count - 1 WHERE id = OLD.from_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value - NEW.amount_value, transactions_count = transactions_count + 1 WHERE id = NEW.from_account_id;


  return NEW;
END

$process_transaction$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS openbill_transaction_update ON OPENBILL_TRANSACTIONS;
CREATE TRIGGER openbill_transaction_update
  AFTER UPDATE ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE openbill_transaction_update();
