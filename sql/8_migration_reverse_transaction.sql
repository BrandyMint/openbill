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
      (to_account_id is null OR to_account_id = NEW.from_account_id) AND
      (from_account_id is null OR from_account_id = NEW.to_account_id) AND
      allow_reverse
    );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No policy for this transaction';
  END IF;

  RETURN NEW;
END

$restrict_transaction$ LANGUAGE plpgsql;

