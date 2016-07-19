CREATE OR REPLACE FUNCTION constraint_accounts_currency_in_transactions() RETURNS TRIGGER AS $process_transaction$
BEGIN
  PERFORM * FROM OPENBILL_ACCOUNTS where id = NEW.from_account_id and amount_currency = NEW.amount_currency;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account (from #%) has wrong currency', NEW.from_account_id;
  END IF;

  PERFORM * FROM OPENBILL_ACCOUNTS where id = NEW.to_account_id and amount_currency = NEW.amount_currency;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account (to #%) has wrong currency', NEW.to_account_id;
  END IF;

  return NEW;
END

$process_transaction$ LANGUAGE plpgsql;

CREATE TRIGGER constraint_accounts_currency_in_transactions
  BEFORE INSERT OR UPDATE ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE constraint_accounts_currency_in_transactions();
