-- current_user

CREATE OR REPLACE FUNCTION add_current_user_to_transaction() RETURNS TRIGGER AS $add_current_user_to_transaction$
BEGIN
  NEW.username := current_user;
  RETURN NEW;
END
$add_current_user_to_transaction$ LANGUAGE plpgsql;

CREATE TRIGGER add_current_user_to_transaction
  BEFORE INSERT OR UPDATE ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE add_current_user_to_transaction();
