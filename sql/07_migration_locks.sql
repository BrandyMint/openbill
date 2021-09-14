CREATE TABLE OPENBILL_LOCKS (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id        UUID,
  username        character varying(255) not null,
  date            date default current_date not null,
  created_at      timestamp without time zone default current_timestamp,
  account_id uuid not null,
  amount_cents    numeric not null,
  amount_currency character varying(8) not null,
  key             character varying(256) UNIQUE not null,
  details         text not null,
  meta            hstore not null default ''::hstore,
  lock_key   character varying(256) not null,
  foreign key (lock_key) REFERENCES OPENBILL_LOCKS (key) ON DELETE RESTRICT ON UPDATE RESTRICT,
  foreign key (account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE UNIQUE INDEX index_locks_on_key ON OPENBILL_LOCKS USING btree (key);
CREATE INDEX index_locks_on_meta ON OPENBILL_LOCKS USING gin (meta);

ALTER TABLE openbill_accounts ADD COLUMN locked_cents numeric not null DEFAULT 0;