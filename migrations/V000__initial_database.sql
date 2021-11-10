CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;

CREATE                TABLE OPENBILL_CATEGORIES (
  id                  bigserial PRIMARY KEY,
  name                character varying(256) not null
);

COMMENT ON TABLE OPENBILL_CATEGORIES IS 'Account category. A convenient way to group accounts, for example: user accounts and system accounts, and also restrict transactions.';
COMMENT ON COLUMN OPENBILL_CATEGORIES.id IS 'Account category id';
COMMENT ON COLUMN OPENBILL_CATEGORIES.name IS 'Account category name';

CREATE UNIQUE INDEX index_openbill_categories_name ON OPENBILL_CATEGORIES USING btree (name);

INSERT INTO OPENBILL_CATEGORIES  (name, id) values ('System', -1);

CREATE                TABLE OPENBILL_ACCOUNTS (
  id                  bigserial PRIMARY KEY,
  category_id         bigint not null,
  amount_value        numeric(36,18) not null default 0,
  amount_currency     character varying(8) not null default 'USD',
  details             text,
  transactions_count  integer not null default 0,
  meta                jsonb not null default '{}'::jsonb,
  created_at          timestamp without time zone default current_timestamp,
  updated_at          timestamp without time zone default current_timestamp,
  foreign key (category_id) REFERENCES OPENBILL_CATEGORIES (id) ON DELETE RESTRICT
);
COMMENT ON TABLE OPENBILL_ACCOUNTS IS 'Account. Has a unique bigint identifier. Has information about the state of the account (balance), currency';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.id IS 'Account unique id';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.category_id IS 'Account category id, referenes on table OPENBILL_CATEGORIES. Use for grouping accounts';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.amount_value IS 'Account balance';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.amount_currency IS 'Account currency';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.details IS 'Account description';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.transactions_count IS 'Number of transactions per account';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.meta IS 'Account description in json format';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.created_at IS 'Date time of account creation';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.updated_at IS 'Date time of account modificaton';



CREATE UNIQUE INDEX index_accounts_on_id ON OPENBILL_ACCOUNTS USING btree (id);
CREATE INDEX index_accounts_on_meta ON OPENBILL_ACCOUNTS USING gin (meta);
CREATE INDEX index_accounts_on_created_at ON OPENBILL_ACCOUNTS USING btree (created_at);

CREATE TABLE OPENBILL_TRANSACTIONS (
  id              bigserial PRIMARY KEY,
  billing_date    date default current_date not null,
  created_at      timestamp without time zone default current_timestamp,
  from_account_id bigint not null,
  to_account_id   bigint not null CONSTRAINT different_accounts CHECK (to_account_id<>from_account_id),
  amount_value    numeric(36,18) not null CONSTRAINT positive CHECK (amount_value>0),
  amount_currency character varying(8) not null default 'USD',
  remote_idempotency_key character varying(256) not null,
  details         text not null,
  meta            jsonb not null default '{}'::jsonb,
  foreign key (from_account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  foreign key (to_account_id) REFERENCES OPENBILL_ACCOUNTS (id)
);
COMMENT ON TABLE OPENBILL_TRANSACTIONS IS 'The operation of transferring funds between accounts. Has a unique identifier, identifiers of incoming and outgoing accounts, transaction amount, description.';
COMMENT ON COLUMN OPENBILL_TRANSACTIONS.id IS 'Transaction unique id';
COMMENT ON COLUMN OPENBILL_TRANSACTIONS.billing_date IS 'Foreign date time of transaction creation';
COMMENT ON COLUMN OPENBILL_TRANSACTIONS.created_at IS 'Date time of transaction creation';
COMMENT ON COLUMN OPENBILL_TRANSACTIONS.from_account_id IS 'Account from which the funds are transferred';
COMMENT ON COLUMN OPENBILL_TRANSACTIONS.to_account_id IS 'Account to which funds are transferred';
COMMENT ON COLUMN OPENBILL_TRANSACTIONS.amount_value IS 'Transfer amount';
COMMENT ON COLUMN OPENBILL_TRANSACTIONS.amount_currency IS 'Transfer currency';
COMMENT ON COLUMN OPENBILL_TRANSACTIONS.details IS 'Transaction description';
COMMENT ON COLUMN OPENBILL_TRANSACTIONS.meta IS 'Transaction description in json format';
COMMENT ON COLUMN OPENBILL_TRANSACTIONS.remote_idempotency_key IS 'Human readable unique transaction key';


CREATE UNIQUE INDEX index_transactions_on_key ON OPENBILL_TRANSACTIONS USING btree (remote_idempotency_key);
CREATE INDEX index_transactions_on_meta ON OPENBILL_TRANSACTIONS USING gin (meta);
CREATE INDEX index_transactions_on_created_at ON OPENBILL_TRANSACTIONS USING btree (created_at);
