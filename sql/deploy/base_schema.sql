-- Deploy conch-locker:base_schema to pg
-- requires: auditlog

BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

CREATE TABLE IF NOT EXISTS conch_locker.vendor (
  id uuid PRIMARY KEY  DEFAULT uuid_generate_v1mc() NOT NULL,
  name text NOT NULL,
  audit_id uuid NOT NULL,
  metadata jsonb
);


CREATE TABLE IF NOT EXISTS conch_locker.location (
  id uuid PRIMARY KEY  DEFAULT uuid_generate_v1mc() NOT NULL,
  name text NOT NULL,
  location_type text NOT NULL,
  parent_id uuid,
  data_center_id uuid,
  vendor_id uuid,
  audit_id uuid NOT NULL,
  metadata jsonb
);

ALTER TABLE conch_locker.location
ADD CONSTRAINT parent_foreign_key FOREIGN KEY (parent_id) REFERENCES conch_locker.location (id);

ALTER TABLE conch_locker.location
ADD CONSTRAINT data_center_foreign_key FOREIGN KEY (data_center_id) REFERENCES conch_locker.location (id);

ALTER TABLE conch_locker.location
ADD CONSTRAINT vendor_foreign_key FOREIGN KEY (vendor_id) REFERENCES conch_locker.vendor (id);

CREATE TABLE IF NOT EXISTS conch_locker.asset (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v1mc() NOT NULL,
  name text NOT NULL,
  asset_type text NOT NULL,
  serial_number text UNIQUE NOT NULL,
  audit_id uuid NOT NULL,
  location_id uuid,
  metadata jsonb
);

ALTER TABLE conch_locker.asset
ADD CONSTRAINT location_foreign_key FOREIGN KEY (location_id) REFERENCES conch_locker.location (id);

CREATE TABLE IF NOT EXISTS conch_locker.part (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v1mc() NOT NULL,
  name text NOT NULL,
  serial_number text UNIQUE NOT NULL,
  asset_id uuid UNIQUE NOT NULL,
  audit_id uuid NOT NULL,
  vendor_id uuid,
  metadata jsonb
);

ALTER TABLE conch_locker.part
ADD CONSTRAINT asset_foreign_key FOREIGN KEY (asset_id) REFERENCES conch_locker.asset (id);

ALTER TABLE conch_locker.part
ADD CONSTRAINT vendor_foreign_key FOREIGN KEY (vendor_id) REFERENCES conch_locker.vendor (id);

CREATE TABLE IF NOT EXISTS conch_locker.asset_part (
  id uuid PRIMARY KEY  DEFAULT uuid_generate_v1mc() NOT NULL,
  asset_id uuid NOT NULL,
  part_id uuid NOT NULL,
  audit_id uuid NOT NULL,
  metadata jsonb
);

ALTER TABLE conch_locker.asset_part
ADD CONSTRAINT asset_foreign_key FOREIGN KEY (asset_id) REFERENCES conch_locker.asset (id);

ALTER TABLE conch_locker.asset_part
ADD CONSTRAINT part_foreign_key FOREIGN KEY (part_id) REFERENCES conch_locker.part (id);

COMMIT;
