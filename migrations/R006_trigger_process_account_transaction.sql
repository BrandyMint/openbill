CREATE OR REPLACE FUNCTION process_account_transaction() RETURNS TRIGGER AS $process_transaction$
DECLARE
 v_account_from OPENBILL_ACCOUNTS%rowtype;
BEGIN
  SELECT * FROM OPENBILL_ACCOUNTS WHERE id = NEW.from_account_id FOR UPDATE INTO v_account_from;
  -- У всех счетов и транзакции должна быть одинаковая валюта

  IF NEW.amount_currency <> v_account_from.amount_currency THEN
    RAISE EXCEPTION 'Account (from #%) has wrong currency', NEW.from_account_id;
  END IF;

  IF NOT EXISTS (SELECT * FROM OPENBILL_ACCOUNTS where id = NEW.to_account_id and amount_currency = NEW.amount_currency) THEN
    RAISE EXCEPTION 'Account (to #%) has wrong currency', NEW.to_account_id;
  END IF;

  IF v_account_from.locked_at IS NOT NULL THEN
    RAISE EXCEPTION 'Account (from #%) is hold from %', NEW.to_account_id, v_account_from.locked_at;
  END IF;

  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value - NEW.amount_value, transactions_count = transactions_count + 1 WHERE id = NEW.from_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value + NEW.amount_value, transactions_count = transactions_count + 1 WHERE id = NEW.to_account_id;

  return NEW;
END

$process_transaction$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS process_account_transaction ON OPENBILL_TRANSACTIONS;
CREATE TRIGGER process_account_transaction
  AFTER INSERT ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE process_account_transaction();
