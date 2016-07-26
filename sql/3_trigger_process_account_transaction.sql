CREATE OR REPLACE FUNCTION process_account_transaction() RETURNS TRIGGER AS $process_transaction$
BEGIN
  -- У всех счетов и транзакции должна быть одинаковая валюта

  IF NEW.operation_id IS NOT NULL THEN
    PERFORM * FROM OPENBIL_OPERATIONS WHERE ID = NEW.operation_id AND from_account_id = NEW.from_account_id AND to_account_id = NEW.to_account_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Operation (#%) has wrong accounts', NEW.operation_id;
    END IF;

  END IF;

  PERFORM * FROM OPENBILL_ACCOUNTS where id = NEW.from_account_id and amount_currency = NEW.amount_currency;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account (from #%) has wrong currency', NEW.from_account_id;
  END IF;

  PERFORM * FROM OPENBILL_ACCOUNTS where id = NEW.to_account_id and amount_currency = NEW.amount_currency;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account (to #%) has wrong currency', NEW.to_account_id;
  END IF;

  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents - NEW.amount_cents, transactions_count = transactions_count + 1 WHERE id = NEW.from_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents + NEW.amount_cents, transactions_count = transactions_count + 1 WHERE id = NEW.to_account_id;

  return NEW;
END

$process_transaction$ LANGUAGE plpgsql;

CREATE TRIGGER process_account_transaction
  AFTER INSERT ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE process_account_transaction();
