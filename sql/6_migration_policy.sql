CREATE                TABLE OPENBILL_POLICIES (
  id                  BIGSERIAL PRIMARY KEY,
  name                character varying(256) not null,
  from_category_id    integer,
  to_category_id      integer,
  from_account_id     integer,
  to_account_id       integer,

  foreign key (from_category_id) REFERENCES OPENBILL_CATEGORIES (id),
  foreign key (to_category_id) REFERENCES OPENBILL_CATEGORIES (id),
  foreign key (from_account_id) REFERENCES OPENBILL_ACCOUNTS (id),
  foreign key (to_account_id) REFERENCES OPENBILL_ACCOUNTS (id)
);

CREATE UNIQUE INDEX index_openbill_policies_name ON OPENBILL_POLICIES USING btree (name);

ALTER TABLE OPENBILL_TRANSACTIONS ADD policy_id integer;
ALTER TABLE OPENBILL_TRANSACTIONS ADD FOREIGN KEY (policy_id) REFERENCES OPENBILL_POLICIES (id);

CREATE OR REPLACE FUNCTION restrict_transaction() RETURNS TRIGGER AS $restrict_transaction$
DECLARE
  _from_category_id integer;
  _to_category_id integer;
BEGIN
  SELECT category_id FROM OPENBILL_ACCOUNTS where id = NEW.from_account_id INTO _from_category_id;
  SELECT category_id FROM OPENBILL_ACCOUNTS where id = NEW.to_account_id INTO _to_category_id;
  SELECT id FROM OPENBILL_POLICIES WHERE 
    (from_category_id is null OR from_category_id = _from_category_id) AND
    (to_category_id is null OR to_category_id = _to_category_id) AND
    (from_account_id is null OR from_account_id = NEW.from_account_id) AND
    (to_account_id is null OR to_account_id = NEW.to_account_id) 
  INTO NEW.policy_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No policy for this transaction';
  END IF;

  RETURN NEW;
END

$restrict_transaction$ LANGUAGE plpgsql;

CREATE TRIGGER restrict_transaction
  AFTER INSERT ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE restrict_transaction();

INSERT INTO OPENBILL_POLICIES (name) VALUES ('Allow any transaction');
