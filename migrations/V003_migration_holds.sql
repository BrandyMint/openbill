CREATE TABLE OPENBILL_HOLDS (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at      timestamp without time zone default current_timestamp,
  account_id uuid not null,
  amount_value    numeric(36,18) not null,
  amount_currency character varying(8) not null default 'USD',
  details         text not null,
  meta            jsonb not null default '{}'::jsonb,
  hold_id   uuid,
  foreign key (hold_id) REFERENCES OPENBILL_HOLDS (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  foreign key (account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK ((amount_value < 0 AND hold_id is NOT NULL) or (amount_value >0 AND hold_id is NULL))
);

CREATE INDEX index_holds_on_meta ON OPENBILL_HOLDS USING gin (meta);

ALTER TABLE openbill_accounts ADD COLUMN hold_value numeric(36,18) not null DEFAULT 0;
