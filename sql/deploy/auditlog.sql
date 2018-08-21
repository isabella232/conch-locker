-- Deploy conch-locker:auditlog to pg
-- requires: appschema

BEGIN;

CREATE SCHEMA cl_log;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

CREATE TABLE IF NOT EXISTS conch_locker.audit_log (
	uuid uuid PRIMARY KEY DEFAULT uuid_generate_v1mc(),
    created timestamp with time zone DEFAULT now() NOT NULL,
    user_account text NOT NULL DEFAULT CURRENT_USER,
    action text NOT NULL,
    table_schema text NOT NULL,
    table_name text NOT NULL,
    previous_id uuid,
    old_row jsonb,
    new_row jsonb,
    CONSTRAINT audit_log_check CHECK ( CASE action WHEN 'INSERT' THEN old_row IS NULL WHEN 'DELETE' THEN new_row IS NULL END )
);

ALTER TABLE conch_locker.audit_log
ADD CONSTRAINT previous_foreign_key FOREIGN KEY (previous_id) REFERENCES conch_locker.audit_log (uuid);

CREATE OR REPLACE FUNCTION add_logging_items(schema_name TEXT, table_name TEXT)
RETURNS VOID
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN

    EXECUTE format('CREATE TABLE IF NOT EXISTS cl_log.%I(
    CHECK(table_schema = %L)
) INHERITS(%s.audit_log);',
        pg_catalog.concat_ws('_', schema_name, 'log'),
        schema_name,
        schema_name
    );

    EXECUTE format('CREATE TABLE IF NOT EXISTS cl_log.%I(
    CHECK (table_name = %L)
) INHERITS(cl_log.%s)',
        pg_catalog.concat_ws('_', schema_name, table_name, 'log'),
        table_name,
        pg_catalog.concat_ws('_', schema_name, 'log')
    );

    EXECUTE format(
            $q$CREATE OR REPLACE FUNCTION %I()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $trig$
BEGIN

    INSERT INTO cl_log.%I (
        action,
        table_schema,
        table_name,
        previous_id,
        old_row,
        new_row
    )
    VALUES (
        TG_OP,
        TG_TABLE_SCHEMA,
        TG_RELNAME,
        CASE WHEN TG_OP <> 'INSERT' THEN OLD.audit_id END,
        CASE WHEN TG_OP <> 'INSERT' THEN row_to_json(OLD)::jsonb END,
        CASE WHEN TG_OP <> 'DELETE' THEN row_to_json(NEW)::jsonb END
    ) RETURNING uuid INTO STRICT NEW.audit_id;

    RETURN NEW;
END;
$trig$;

CREATE TRIGGER %I
    BEFORE INSERT OR UPDATE OR DELETE ON %I.%I
    FOR EACH ROW
        EXECUTE PROCEDURE %I();$q$,
            pg_catalog.concat_ws('_', 'log', schema_name, table_name),
            pg_catalog.concat_ws('_', schema_name, table_name, 'log'),
            pg_catalog.concat_ws('_', 'log', schema_name, table_name),
            schema_name,
            table_name,
            pg_catalog.concat_ws('_', 'log', schema_name, table_name)
    );
RETURN;
END;
$$;

COMMENT ON FUNCTION add_logging_items(schema_name TEXT, table_name TEXT) IS $$This is a stand-alone function in case we need to back-fill$$;

CREATE OR REPLACE FUNCTION add_logger()
RETURNS event_trigger
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN

    SELECT p.*, c.relname as table_name INTO STRICT r
    FROM
        pg_catalog.pg_event_trigger_ddl_commands() p
    JOIN
        pg_catalog.pg_class c
        ON (p.objid = c.oid)
    WHERE
        p.object_type = 'table' AND
        c.relname !~ '_log$'; /* Let's not recurse here ;) */

    IF NOT FOUND THEN
        RETURN;
    END IF;

    PERFORM add_logging_items(r.schema_name, r.table_name);

    EXCEPTION
        WHEN no_data_found THEN
            NULL;
        WHEN too_many_rows THEN
            RAISE EXCEPTION 'This function should only fire on one table, not this list: %', r.object_identity;
END;
$$;

CREATE EVENT TRIGGER add_logger
    ON ddl_command_end
    WHEN tag IN ('create table')
        EXECUTE PROCEDURE add_logger();

COMMIT;
