ALTER TABLE OPENBILL_POLICIES ADD allow_reverse boolean not null default true;
ALTER TABLE OPENBILL_TRANSACTIONS ADD reverse_transaction_id uuid;
ALTER TABLE OPENBILL_TRANSACTIONS ADD CONSTRAINT reverse_transaction_foreign_key FOREIGN KEY (reverse_transaction_id) REFERENCES OPENBILL_TRANSACTIONS (id);

CREATE OR REPLACE FUNCTION restrict_transaction() RETURNS TRIGGER AS $restrict_transaction$
DECLARE
  _from_category_id uuid;
  _to_category_id uuid;
BEGIN
  SELECT category_id FROM OPENBILL_ACCOUNTS where id = NEW.from_account_id INTO _from_category_id;
  SELECT category_id FROM OPENBILL_ACCOUNTS where id = NEW.to_account_id INTO _to_category_id;
  PERFORM * FROM OPENBILL_POLICIES WHERE 
    (
      NEW.reverse_transaction_id is null AND
      (from_category_id is null OR from_category_id = _from_category_id) AND
      (to_category_id is null OR to_category_id = _to_category_id) AND
      (from_account_id is null OR from_account_id = NEW.from_account_id) AND
      (to_account_id is null OR to_account_id = NEW.to_account_id)
    ) OR
    (
      NEW.reverse_transaction_id is not null AND
      (to_category_id is null OR to_category_id = _from_category_id) AND
      (from_category_id is null OR from_category_id = _to_category_id) AND
      (to_category_id is null OR to_category_id = NEW.from_account_id) AND
      (from_category_ID is null OR from_category_ID = NEW.to_account_id) AND
      allow_reverse
    );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No policy for this transaction';
  END IF;

  RETURN NEW;
END

$restrict_transaction$ LANGUAGE plpgsql;


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

  IF NEW.reverse_transaction_id IS NOT NULL THEN
    PERFORM * FROM openbill_transactions
      WHERE amount_cents = NEW.amount_cents 
        AND amount_currency = NEW.amount_currency 
        AND from_account_id = NEW.to_account_id
        AND to_account_id = NEW.from_account_id
        AND id = NEW.reverse_transaction_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Not found reverse transaction with same accounts and amount (#%)', NEW.reverse_transaction_id;
    END IF;

  END IF;

  -- установить last_transaction_id, counts и _at
  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents - NEW.amount_cents, last_transaction_id = NEW.id, last_transaction_at = NEW.created_at, transactions_count = transactions_count + 1 WHERE id = NEW.from_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents + NEW.amount_cents, last_transaction_id = NEW.id, last_transaction_at = NEW.created_at, transactions_count = transactions_count + 1 WHERE id = NEW.to_account_id;

  return NEW;
END

$process_transaction$ LANGUAGE plpgsql;

