CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

CREATE                TABLE OPENBILL_CATEGORIES (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name                character varying(256) not null,
  parent_id           uuid,
  foreign key (parent_id) REFERENCES OPENBILL_CATEGORIES (id) ON DELETE RESTRICT
);

COMMENT ON TABLE OPENBILL_CATEGORIES IS 'Account category. A convenient way to group accounts, for example: user accounts and system accounts, and also restrict transactions.';
COMMENT ON COLUMN OPENBILL_CATEGORIES.id IS 'Account category id';
COMMENT ON COLUMN OPENBILL_CATEGORIES.name IS 'Account category name';
COMMENT ON COLUMN OPENBILL_CATEGORIES.parent_id IS 'Account category parent id';

CREATE UNIQUE INDEX index_openbill_categories_name ON OPENBILL_CATEGORIES USING btree (parent_id, name);

INSERT INTO OPENBILL_CATEGORIES  (name, id) values ('System', '12832d8d-43f5-499b-82a1-3466cadcd809');

CREATE                TABLE OPENBILL_ACCOUNTS (
  owner_id            UUID,
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id         uuid not null,
  key                 character varying(256),
  amount_value        numeric(36,18) not null default 0,
  amount_currency     character varying(8) not null default 'USD',
  details             text,
  transactions_count  integer not null default 0,
  meta                jsonb not null default '{}'::jsonb,
  created_at          timestamp without time zone default current_timestamp,
  updated_at          timestamp without time zone default current_timestamp,
  foreign key (category_id) REFERENCES OPENBILL_CATEGORIES (id) ON DELETE RESTRICT
);
COMMENT ON TABLE OPENBILL_ACCOUNTS IS 'Account. Has a unique uuid identifier. Has information about the state of the account (balance), currency';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.id IS 'Account unique id';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.category_id IS 'Account category id, references on table OPENBILL_CATEGORIES. Use for grouping accounts';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.amount_value IS 'Account balance';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.amount_currency IS 'Account currency';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.details IS 'Account description';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.transactions_count IS 'Number of transactions per account';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.meta IS 'Account description in json format';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.created_at IS 'Date time of account creation';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.updated_at IS 'Date time of account modificaton';



CREATE UNIQUE INDEX index_accounts_on_id ON OPENBILL_ACCOUNTS USING btree (id);
CREATE UNIQUE INDEX index_accounts_on_key ON OPENBILL_ACCOUNTS USING btree (key) WHERE key is not null;
CREATE INDEX index_accounts_on_meta ON OPENBILL_ACCOUNTS USING gin (meta);
CREATE INDEX index_accounts_on_created_at ON OPENBILL_ACCOUNTS USING btree (created_at);

CREATE TABLE OPENBILL_TRANSACTIONS (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id        UUID,
  username        character varying(255) not null,
  date            date default current_date not null,
  created_at      timestamp without time zone default current_timestamp,
  from_account_id uuid not null,
  to_account_id   uuid not null CONSTRAINT different_accounts CHECK (to_account_id<>from_account_id),
  amount_value    numeric(36,18) not null CONSTRAINT positive CHECK (amount_value>0),
  amount_currency character varying(8) not null default 'USD',
  key             character varying(256) not null,
  details         text not null,
  meta            jsonb not null default '{}'::jsonb,
  foreign key (from_account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  foreign key (to_account_id) REFERENCES OPENBILL_ACCOUNTS (id)
);
COMMENT ON TABLE OPENBILL_ACCOUNTS IS 'the operation of transferring funds between accounts. Has a unique identifier, identifiers of incoming and outgoing accounts, transaction amount, description.';



CREATE UNIQUE INDEX index_transactions_on_key ON OPENBILL_TRANSACTIONS USING btree (key);
CREATE INDEX index_transactions_on_meta ON OPENBILL_TRANSACTIONS USING gin (meta);
CREATE INDEX index_transactions_on_created_at ON OPENBILL_TRANSACTIONS USING btree (created_at);
