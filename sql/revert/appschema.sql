-- Revert conch-locker:appschema from pg

BEGIN;

DROP SCHEMA conch_locker CASCADE;

COMMIT;
