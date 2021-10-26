ALTER TABLE OPENBILL_POLICIES ADD allow_reverse boolean not null default true;
ALTER TABLE OPENBILL_TRANSACTIONS ADD reverse_transaction_id uuid;
ALTER TABLE OPENBILL_TRANSACTIONS ADD CONSTRAINT reverse_transaction_foreign_key FOREIGN KEY (reverse_transaction_id) REFERENCES OPENBILL_TRANSACTIONS (id);
