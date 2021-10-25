ALTER TABLE openbill_accounts ADD COLUMN kind smallint NOT NULL DEFAULT 3;
alter table openbill_accounts
   add constraint openbill_accounts_kind_type0 check (kind = 0 AND amount_value>=0);
   alter table openbill_accounts
      add constraint openbill_accounts_kind_type1 check (kind = 1 AND amount_value<=0);

COMMENT ON COLUMN openbill_accounts.kind IS 'Тип аккаунта';
