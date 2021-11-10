CREATE OR REPLACE FUNCTION notify_transaction() RETURNS TRIGGER AS $notify_transaction$
BEGIN
  PERFORM pg_notify('openbill_transactions', CAST(NEW.id AS text));

  return NEW;
END

$notify_transaction$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS notify_transaction ON OPENBILL_TRANSACTIONS;
CREATE TRIGGER notify_transaction
  AFTER INSERT ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE notify_transaction();
