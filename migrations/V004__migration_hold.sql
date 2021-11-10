ALTER TABLE openbill_accounts ADD COLUMN locked_at timestamp without time zone null;

COMMENT ON COLUMN openbill_accounts.locked_at IS 'The date the funds were holded. If the value is NULL there is no blocking';
