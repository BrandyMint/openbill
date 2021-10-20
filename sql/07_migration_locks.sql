CREATE TABLE OPENBILL_HOLDS (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id        UUID,
  username        character varying(255) not null,
  date            date default current_date not null,
  created_at      timestamp without time zone default current_timestamp,
  account_id uuid not null,
  amount_value    numeric(36,18) not null,
  amount_currency character varying(8) not null default 'USD',
  key             character varying(256) UNIQUE not null,
  details         text not null,
  meta            jsonb not null default '{}'::jsonb,
  hold_key   character varying(256),
  foreign key (hold_key) REFERENCES OPENBILL_HOLDS (key) ON DELETE RESTRICT ON UPDATE RESTRICT,
  foreign key (account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK ((amount_value < 0 AND hold_key is NOT NULL) or (amount_value >0 AND hold_key is NULL))
);

CREATE UNIQUE INDEX index_holds_on_key ON OPENBILL_HOLDS USING btree (key);
CREATE INDEX index_holds_on_meta ON OPENBILL_HOLDS USING gin (meta);

ALTER TABLE openbill_accounts ADD COLUMN hold_value numeric(36,18) not null DEFAULT 0;
