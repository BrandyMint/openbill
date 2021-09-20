CREATE OR REPLACE FUNCTION OPENBILL_LOCKS_insert() RETURNS TRIGGER AS $process_transaction$
DECLARE
 v_account OPENBILL_ACCOUNTS%rowtype;
 v_lock_amount numeric;
 v_unlock_amount numeric;
BEGIN
  NEW.username := current_user;
  SELECT * FROM OPENBILL_ACCOUNTS WHERE id = NEW.account_id INTO v_account;
  -- У всех счетов и транзакции должна быть одинаковая валюта

  IF v_account.amount_currency <> NEW.amount_currency THEN
    RAISE EXCEPTION 'Account (from #%) has wrong currency', NEW.account_id;
  END IF;
  -- Нельзя заблокировать больше чем есть на счете
  IF NEW.amount_cents > 0 AND NEW.amount_cents > v_account.amount_cents THEN
    RAISE EXCEPTION 'It is impossible to block the amount more than is on the account';
  END IF;

  -- Нельзя разблокировать больше чем есть на счете
  IF NEW.amount_cents < 0 THEN
    SELECT amount_cents FROM OPENBILL_LOCKS WHERE key = NEW.lock_key INTO v_lock_amount;
    SELECT SUM(amount_cents) FROM OPENBILL_LOCKS WHERE lock_key = NEW.lock_key INTO v_unlock_amount;
    v_lock_amount = v_lock_amount + v_unlock_amount;
    RAISE NOTICE 'v_lock_amount: %, v_account.locked_cents: %, -NEW.amount_cents: %', v_lock_amount, v_account.locked_cents, -NEW.amount_cents;
    IF v_lock_amount < -NEW.amount_cents OR v_account.locked_cents < -NEW.amount_cents THEN
      RAISE EXCEPTION 'It is impossible to unblock the amount more than is on the account';
    END IF;
  END IF;


  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents - NEW.amount_cents, locked_cents = locked_cents + NEW.amount_cents WHERE id = NEW.account_id;

  return NEW;
END

$process_transaction$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS OPENBILL_LOCKS_insert ON OPENBILL_LOCKS;
CREATE TRIGGER OPENBILL_LOCKS_insert
  BEFORE INSERT ON OPENBILL_LOCKS FOR EACH ROW EXECUTE PROCEDURE OPENBILL_LOCKS_insert();
