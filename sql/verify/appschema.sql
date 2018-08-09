-- Verify conch-locker:appschema on pg

BEGIN;

SELECT pg_catalog.has_schema_privilege('conch_locker', 'usage');

ROLLBACK;
