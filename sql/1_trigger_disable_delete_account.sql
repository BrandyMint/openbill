-- Disable delete and update in OPENBILL_ACCOUNTS

CREATE OR REPLACE FUNCTION disable_update_account() RETURNS TRIGGER AS $disable_update_account$
DECLARE
  query text;
BEGIN
  IF current_query() like 'insert into OPENBILL_TRANSACTIONS%' THEN
    RETURN NEW;
  ELSE
    RAISE EXCEPTION 'Cannot directly update amount_cents and timestamps of account with query (#%)', current_query();
  END IF;
END

$disable_update_account$ LANGUAGE plpgsql;

-- временно отключаем, так как она не правильно срабатывает на операциях типа INSERT INTO "openbill_transactions"
-- CREATE TRIGGER disable_update_account
  -- BEFORE UPDATE ON OPENBILL_ACCOUNTS FOR EACH ROW EXECUTE PROCEDURE disable_update_account();

CREATE OR REPLACE FUNCTION disable_delete_account() RETURNS TRIGGER AS $disable_delete_account$
BEGIN
  RAISE EXCEPTION 'Cannot delete account';
END

$disable_delete_account$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS disable_delete_account ON OPENBILL_ACCOUNTS;
CREATE TRIGGER disable_delete_account
  BEFORE DELETE ON OPENBILL_ACCOUNTS FOR EACH ROW EXECUTE PROCEDURE disable_delete_account();
