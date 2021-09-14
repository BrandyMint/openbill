CREATE OR REPLACE FUNCTION OPENBILL_LOCKS_insert() RETURNS TRIGGER AS $process_transaction$
DECLARE
 v_account OPENBILL_ACCOUNTS%rowtype;
BEGIN
  SELECT * FROM OPENBILL_ACCOUNTS WHERE id = NEW.account_id INTO v_account;
  -- У всех счетов и транзакции должна быть одинаковая валюта

  IF v_account.amount_currency <> NEW.amount_currency THEN
    RAISE EXCEPTION 'Account (from #%) has wrong currency', NEW.account_id;
  END IF;
  -- Нельзя заблокировать больше чем есть на счете
  IF NEW.amount_cents > 0 AND NEW.amount_cents > v_account.amount_cents THEN
    RAISE EXCEPTION 'It is impossible to block the amount more than is on the account %', NEW.to_account_id;
  END IF;

  -- Некорректный запрос на разблокировку
  IF NEW.amount_cents < 0 AND  NEW.lock_key IS NULL THEN
    RAISE EXCEPTION 'Invalid unlock request';
  END IF;

  -- Нельзя разблокировать больше чем есть на счете
  IF NEW.amount_cents < 0 AND  -NEW.amount_cents > v_account.locked_cents THEN
    RAISE EXCEPTION 'It is impossible to unblock the amount more than is on the account %', NEW.to_account_id;
  END IF;


  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents - NEW.amount_cents, locked_cents = locked_cents + NEW.amount_cents WHERE id = NEW.from_account_id;

  return NEW;
END

$process_transaction$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS OPENBILL_LOCKS_insert ON OPENBILL_LOCKS;
CREATE TRIGGER OPENBILL_LOCKS_insert
  AFTER INSERT ON OPENBILL_LOCKS FOR EACH ROW EXECUTE PROCEDURE process_account_transaction();
