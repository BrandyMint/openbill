CREATE TYPE account_kind AS ENUM ('negative', 'positive', 'any');
ALTER TABLE openbill_accounts ADD COLUMN kind account_kind NOT NULL DEFAULT 'any';
alter table openbill_accounts
   add constraint openbill_accounts_kind check ( (kind = 'positive' AND amount_value >=0) OR (kind = 'negative' AND amount_value<=0) OR kind = 'any' );

COMMENT ON COLUMN openbill_accounts.kind IS 'Account type';
