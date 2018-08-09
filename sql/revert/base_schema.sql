-- Revert conch-locker:base_schema from pg

BEGIN;

DROP TABLE IF EXISTS conch_locker.asset CASCADE;
DROP TABLE IF EXISTS conch_locker.business CASCADE;
DROP TABLE IF EXISTS conch_locker.location CASCADE;
DROP TABLE IF EXISTS conch_locker.manifest CASCADE;
DROP TABLE IF EXISTS conch_locker.manifest_item CASCADE;
DROP TABLE IF EXISTS conch_locker.part CASCADE;

DROP TABLE IF EXISTS cl_log.asset_log;
DROP TABLE IF EXISTS cl_log.business_log;
DROP TABLE IF EXISTS cl_log.location_log;
DROP TABLE IF EXISTS cl_log.manifest_log;
DROP TABLE IF EXISTS cl_log.manifest_item_log;
DROP TABLE IF EXISTS cl_log.part_log;

COMMIT;
