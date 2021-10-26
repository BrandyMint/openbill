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

CREATE UNIQUE INDEX index_openbill_policies_name ON OPENBILL_POLICIES USING btree (name);

INSERT INTO OPENBILL_POLICIES (name) VALUES ('Allow any transactions');
