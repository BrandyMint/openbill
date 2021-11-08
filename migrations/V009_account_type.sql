CREATE TYPE account_kind AS ENUM ('negative', 'positive', 'any');
ALTER TABLE openbill_accounts ADD COLUMN kind account_kind NOT NULL DEFAULT 'any';
alter table openbill_accounts
   add constraint openbill_accounts_kind_type0 check (kind = 'positive' AND amount_value>=0);
   alter table openbill_accounts
      add constraint openbill_accounts_kind_type1 check (kind = 'negative' AND amount_value<=0);

COMMENT ON COLUMN openbill_accounts.kind IS 'Account type;
