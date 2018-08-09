-- Revert conch-locker:auditlog from pg

BEGIN;

DROP TABLE IF EXISTS conch_locker.audit_log CASCADE;
DROP FUNCTION IF EXISTS add_logging_items(text, text) CASCADE;
DROP FUNCTION IF EXISTS add_logger() CASCADE;
DROP SCHEMA cl_log;

COMMIT;
