CREATE OR REPLACE FUNCTION OPENBILL_HOLDS_insert() RETURNS TRIGGER AS $process_transaction$
DECLARE
 v_account OPENBILL_ACCOUNTS%rowtype;
 v_lock_amount numeric(36,18);
 v_unlock_amount numeric(36,18);
BEGIN
  NEW.username := current_user;
  SELECT * FROM OPENBILL_ACCOUNTS WHERE id = NEW.account_id INTO v_account;
  -- У всех счетов и транзакции должна быть одинаковая валюта

  IF v_account.amount_currency <> NEW.amount_currency THEN
    RAISE EXCEPTION 'Account (from #%) has wrong currency', NEW.account_id;
  END IF;
  -- Нельзя заблокировать больше чем есть на счете
  IF NEW.amount_value > 0 AND NEW.amount_value > v_account.amount_value THEN
    RAISE EXCEPTION 'It is impossible to block the amount more than is on the account';
  END IF;

  -- Нельзя разблокировать больше чем есть на счете
  IF NEW.amount_value < 0 THEN
    SELECT amount_value FROM OPENBILL_HOLDS WHERE key = NEW.hold_key INTO v_lock_amount;
    SELECT SUM(amount_value) FROM OPENBILL_HOLDS WHERE hold_key = NEW.hold_key INTO v_unlock_amount;
    v_lock_amount = v_lock_amount + v_unlock_amount;
    IF v_lock_amount < -NEW.amount_value OR v_account.locked_value < -NEW.amount_value THEN
      RAISE EXCEPTION 'It is impossible to unblock the amount more than is on the account';
    END IF;
  END IF;


  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value - NEW.amount_value, locked_value = locked_value + NEW.amount_value WHERE id = NEW.account_id;

  return NEW;
END

$process_transaction$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS OPENBILL_HOLDS_insert ON OPENBILL_HOLDS;
CREATE TRIGGER OPENBILL_HOLDS_insert
  BEFORE INSERT ON OPENBILL_HOLDS FOR EACH ROW EXECUTE PROCEDURE OPENBILL_HOLDS_insert();