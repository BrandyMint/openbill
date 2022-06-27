-- Disable delete and update in OPENBILL_ACCOUNTS

CREATE OR REPLACE FUNCTION create_account() RETURNS TRIGGER AS $$
DECLARE
  query text;
BEGIN
  IF NEW.amount_value <> 0 OR NEW.hold_value <> 0 THEN
    RAISE EXCEPTION 'When creating an account, the balance must be equal to 0';
  END IF;
 RETURN NEW;
END

$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS create_account ON OPENBILL_ACCOUNTS;
CREATE TRIGGER create_account
  BEFORE INSERT ON OPENBILL_ACCOUNTS FOR EACH ROW EXECUTE PROCEDURE create_account();
