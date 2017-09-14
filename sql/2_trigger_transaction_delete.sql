CREATE OR REPLACE FUNCTION openbill_transaction_delete() RETURNS TRIGGER SECURITY DEFINER AS $process_transaction$
BEGIN
  -- установить last_transaction_id, counts и _at
  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents - OLD.amount_cents, transactions_count = transactions_count - 1 WHERE id = OLD.to_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents + OLD.amount_cents, transactions_count = transactions_count - 1 WHERE id = OLD.from_account_id;

  UPDATE OPENBILL_INVOICES SET paied_cents = -OLD.amount_cents WHERE id = OLD.invoice_id;

  return OLD;
END

$process_transaction$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS openbill_transaction_delete ON OPENBILL_TRANSACTIONS;
CREATE TRIGGER openbill_transaction_delete
  BEFORE DELETE ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE openbill_transaction_delete();
