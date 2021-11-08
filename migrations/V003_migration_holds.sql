CREATE TABLE OPENBILL_HOLDS (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date            date default current_date not null,
  created_at      timestamp without time zone default current_timestamp,
  account_id uuid not null,
  amount_value    numeric(36,18) not null,
  amount_currency character varying(8) not null default 'USD',
  remote_idempotency_key             character varying(256) UNIQUE not null,
  details         text not null,
  meta            jsonb not null default '{}'::jsonb,
  hold_key   character varying(256),
  foreign key (hold_key) REFERENCES OPENBILL_HOLDS (remote_idempotency_key) ON DELETE RESTRICT ON UPDATE RESTRICT,
  foreign key (account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK ((amount_value < 0 AND hold_key is NOT NULL) or (amount_value >0 AND hold_key is NULL))
);

CREATE UNIQUE INDEX index_holds_on_key ON OPENBILL_HOLDS USING btree (remote_idempotency_key);
CREATE INDEX index_holds_on_meta ON OPENBILL_HOLDS USING gin (meta);

COMMENT ON TABLE OPENBILL_HOLDS IS 'Оperation of blocking funds on the account. Has a unique identifier, account identifier, blocking amount, description.';
COMMENT ON COLUMN OPENBILL_HOLDS.id IS 'Hold unique id';
COMMENT ON COLUMN OPENBILL_HOLDS.date IS 'Foreign date time of hold creation';
COMMENT ON COLUMN OPENBILL_HOLDS.created_at IS 'Date time of hold creation';
COMMENT ON COLUMN OPENBILL_HOLDS.account_id IS 'Account which the funds are holded';
COMMENT ON COLUMN OPENBILL_HOLDS.amount_value IS 'Hold amount';
COMMENT ON COLUMN OPENBILL_HOLDS.amount_currency IS 'Hold currency';
COMMENT ON COLUMN OPENBILL_HOLDS.details IS 'Hold description';
COMMENT ON COLUMN OPENBILL_HOLDS.meta IS 'Hold description in json format';
COMMENT ON COLUMN OPENBILL_HOLDS.remote_idempotency_key IS 'Human readable unique hold key';


ALTER TABLE openbill_accounts ADD COLUMN hold_value numeric(36,18) not null DEFAULT 0;
COMMENT ON COLUMN openbill_accounts.hold_value IS 'Hold amount';
