### Assets

Assets are any pieces of equipment we want to track for business reasons. They
may be discrete components (e.g. a Hard Drive,, DIMM chip, PDU, Chassis etc.),
or they may be aggregates.

Aggregates are things which consist of a dozen or so high-level parts (e.g.
racks, servers, switches, PDUs), or a "hard drive kit" that would contain the
drive itself, the required cables, and the referenced tools.

Each asset has a state, NEW, BROKEN, REFURB, WONTFIX, etc..

    CREATE TABLE asset (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        name text NOT NULL,
        type text NOT NULL,
        part_id uuid,
        decomissioned timestamp with time zone,
        audit_id uuid NOT NULL;
        metadata jsonb
    );

### Parts

Parts are the discrete components and consumables. These are the things we
purchase, replace, or repair in our environment.

    CREATE TABLE part (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        name text NOT NULL,
        vendor_id uuid,
        decomissioned timestamp with time zone,
        audit_id uuid NOT NULL;
        metadata jsonb
    );

### Manifests

The Manifests track which assets are where, this is the heart of the "tracking"
in asset tracking. The manifests are split into two parts, a Manifest table
that tracks the specific collections of items, and the ManifestItems table that
tracks which items are included in each manifest.

Every aggregate component should have a manifest associated with it.

Manifests may be used to create BOMs and potentially budgets.

    CREATE TABLE manifest (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        name text NOT NULL,
        audit_id uuid NOT NULL;
        metadata jsonb
    );

    CREATE TABLE manifest_item (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        manifest_id uuid NOT NULL,
        asset_id uuid NOT NULL,
        audit_id uuid NOT NULL;
        metadata jsonb
    );

### Locations

Locations are exactly that, they are the locations of an asset or
sub-location.

    CREATE TABLE location (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        name text NOT NULL,
        parent_id uuid,
        data_center_id uuid,
        audit_id uuid NOT NULL;
        metadata jsonb
    );

### Businesses

Businesses are vendors, contractors, manufacturers, suppliers, clients etc.
Anybody we need to track who the human contact is basically.

    CREATE TABLE business (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        name text NOT NULL,
        audit_id uuid NOT NULL;
        metadata jsonb
    );


### Auditing

Because data integrity is vital to this system, we need to track every change
to the system at an atomic level. This is borrowed heavily from
https://github.com/2ndQuadrant/audit-trigger/blob/master/audit.sql

	CREATE TABLE audit_log (
		id uuid DEFAULT gen_random_uuid() NOT NULL primary key,
		schema_name text not null,
		table_name text not null,
		relid oid not null,
		session_user_name text,
		action_tstamp_tx TIMESTAMP WITH TIME ZONE NOT NULL,
		action_tstamp_stm TIMESTAMP WITH TIME ZONE NOT NULL,
		action_tstamp_clk TIMESTAMP WITH TIME ZONE NOT NULL,
		transaction_id bigint,
		application_name text,
		client_addr inet,
		client_port integer,
		client_query text,
		action TEXT NOT NULL CHECK (action IN ('I','D','U', 'T')),
		row_data jsonb,
		changed_fields jsonb,
		statement_only boolean not null
	);
