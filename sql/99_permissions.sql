GRANT SELECT, INSERT, UPDATE ON OPENBILL_CATEGORIES TO public;
GRANT SELECT, INSERT, DELETE  ON OPENBILL_ACCOUNTS TO public;
--GRANT UPDATE ( owner_id, id, category_id, key, amount_currency,
--    details, transactions_count, meta hstore, updated_at) ON OPENBILL_ACCOUNTS TO public;
GRANT SELECT, INSERT ON OPENBILL_TRANSACTIONS TO public;
GRANT SELECT, INSERT, UPDATE ON openbill_invoices TO public;
GRANT SELECT, INSERT, UPDATE, DELETE ON openbill_policies TO public;

GRANT INSERT ON OPENBILL_LOCKS TO public;