use utf8;
package Conch::Locker::DB::Result::Asset;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Conch::Locker::DB::Result::Asset

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::Helper::Row::ToJSON>

=item * L<Conch::Locker::DB::InflateColumn::JSON>

=back

=cut

__PACKAGE__->load_components(
  "Helper::Row::ToJSON",
  "+Conch::Locker::DB::InflateColumn::JSON",
);

=head1 TABLE: C<conch_locker.asset>

=cut

__PACKAGE__->table("conch_locker.asset");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  default_value: uuid_generate_v1mc()
  is_nullable: 0
  size: 16

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 asset_type

  data_type: 'text'
  is_nullable: 0

=head2 serial_number

  data_type: 'text'
  is_nullable: 0

=head2 audit_id

  data_type: 'uuid'
  is_nullable: 0
  size: 16

=head2 location_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 1
  size: 16

=head2 metadata

  data_type: 'jsonb'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v1mc()",
    is_nullable => 0,
    size => 16,
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "asset_type",
  { data_type => "text", is_nullable => 0 },
  "serial_number",
  { data_type => "text", is_nullable => 0 },
  "audit_id",
  { data_type => "uuid", is_nullable => 0, size => 16 },
  "location_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 1, size => 16 },
  "metadata",
  { data_type => "jsonb", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<asset_serial_number_key>

=over 4

=item * L</serial_number>

=back

=cut

__PACKAGE__->add_unique_constraint("asset_serial_number_key", ["serial_number"]);

=head1 RELATIONS

=head2 asset_parts

Type: has_many

Related object: L<Conch::Locker::DB::Result::AssetPart>

=cut

__PACKAGE__->has_many(
  "asset_parts",
  "Conch::Locker::DB::Result::AssetPart",
  { "foreign.asset_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 location

Type: belongs_to

Related object: L<Conch::Locker::DB::Result::Location>

=cut

__PACKAGE__->belongs_to(
  "location",
  "Conch::Locker::DB::Result::Location",
  { id => "location_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 part

Type: might_have

Related object: L<Conch::Locker::DB::Result::Part>

=cut

__PACKAGE__->might_have(
  "part",
  "Conch::Locker::DB::Result::Part",
  { "foreign.asset_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-14 19:55:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yYRovWObUbEjc9n/jxJi2g

use 5.26.0;
use experimental 'signatures';

__PACKAGE__->many_to_many( components => 'asset_parts', 'part' );

__PACKAGE__->belongs_to(
    'audit_log',
    'Conch::Locker::DB::Result::AuditLog',
    { "foreign.uuid" => "self.audit_id" },
);

1;
