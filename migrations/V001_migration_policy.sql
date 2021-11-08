CREATE                TABLE OPENBILL_POLICIES (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name                character varying(256) not null,
  from_category_id    uuid,
  to_category_id      uuid,
  from_account_id     uuid,
  to_account_id       uuid,

  foreign key (from_category_id) REFERENCES OPENBILL_CATEGORIES (id),
  foreign key (to_category_id) REFERENCES OPENBILL_CATEGORIES (id),
  foreign key (from_account_id) REFERENCES OPENBILL_ACCOUNTS (id),
  foreign key (to_account_id) REFERENCES OPENBILL_ACCOUNTS (id)
);

COMMENT ON TABLE OPENBILL_POLICIES IS 'Funds transfer policies. Using this table, you can restrict the movement of funds between accounts. For example, allow write-offs from user accounts only to system ones.';
COMMENT ON COLUMN OPENBILL_POLICIES.id IS 'Policy unique id';
COMMENT ON COLUMN OPENBILL_POLICIES.name IS 'Policy name';
COMMENT ON COLUMN OPENBILL_POLICIES.from_category_id IS 'Category of accounts from which transfers are possible (NULL for all)';
COMMENT ON COLUMN OPENBILL_POLICIES.to_category_id IS 'Category of accounts to which transfers are possible (NULL for all)';
COMMENT ON COLUMN OPENBILL_POLICIES.to_account_id IS 'Fccounts to which transfers are possible (NULL for all)';
COMMENT ON COLUMN OPENBILL_POLICIES.from_account_id IS 'Accounts from which transfers are possible (NULL for all)';

CREATE UNIQUE INDEX index_openbill_policies_name ON OPENBILL_POLICIES USING btree (name);

INSERT INTO OPENBILL_POLICIES (name) VALUES ('Allow any transactions');
