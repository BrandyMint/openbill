ALTER TABLE OPENBILL_TRANSACTIONS ADD invoice_id UUID;

CREATE TABLE openbill_invoices (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    date timestamp without time zone NOT NULL default current_date,
    number character varying(256) NOT NULL,
    title character varying(256) NOT NULL,
    destination_account_id uuid NOT NULL,
    amount_cents numeric DEFAULT 0 NOT NULL,
    amount_currency varchar(8) DEFAULT 'USD'::bpchar NOT NULL,
    paid_cents numeric DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    meta jsonb DEFAULT '{}'::json,
    details text
);

ALTER TABLE ONLY openbill_invoices
    ADD CONSTRAINT openbill_invoices_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX index_invoices_on_id ON openbill_invoices USING btree (id);
CREATE UNIQUE INDEX index_invoices_on_number ON openbill_invoices USING btree (number);

ALTER TABLE ONLY openbill_invoices
    ADD CONSTRAINT openbill_invoices_destination_account_id_fkey FOREIGN KEY (destination_account_id) REFERENCES openbill_accounts(id) ON DELETE RESTRICT;

ALTER TABLE ONLY openbill_transactions
    ADD CONSTRAINT openbill_transactions_invoice_id_fk FOREIGN KEY (invoice_id) REFERENCES openbill_invoices(id) ON DELETE RESTRICT;
