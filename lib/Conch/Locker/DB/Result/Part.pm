use utf8;
package Conch::Locker::DB::Result::Part;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Conch::Locker::DB::Result::Part

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

=head1 TABLE: C<conch_locker.part>

=cut

__PACKAGE__->table("conch_locker.part");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  default_value: uuid_generate_v1mc()
  is_nullable: 0
  size: 16

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 serial_number

  data_type: 'text'
  is_nullable: 0

=head2 asset_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 audit_id

  data_type: 'uuid'
  is_nullable: 0
  size: 16

=head2 vendor_id

  data_type: 'uuid'
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
  "serial_number",
  { data_type => "text", is_nullable => 0 },
  "asset_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "audit_id",
  { data_type => "uuid", is_nullable => 0, size => 16 },
  "vendor_id",
  { data_type => "uuid", is_nullable => 1, size => 16 },
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

=head2 C<part_asset_id_key>

=over 4

=item * L</asset_id>

=back

=cut

__PACKAGE__->add_unique_constraint("part_asset_id_key", ["asset_id"]);

=head2 C<part_serial_number_key>

=over 4

=item * L</serial_number>

=back

=cut

__PACKAGE__->add_unique_constraint("part_serial_number_key", ["serial_number"]);

=head1 RELATIONS

=head2 asset

Type: belongs_to

Related object: L<Conch::Locker::DB::Result::Asset>

=cut

__PACKAGE__->belongs_to(
  "asset",
  "Conch::Locker::DB::Result::Asset",
  { id => "asset_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 asset_parts

Type: has_many

Related object: L<Conch::Locker::DB::Result::AssetPart>

=cut

__PACKAGE__->has_many(
  "asset_parts",
  "Conch::Locker::DB::Result::AssetPart",
  { "foreign.part_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-09 03:27:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HDOBv2nybKH2JvYvz6Xf9A

use 5.26.0;
use experimental 'signatures';

__PACKAGE__->many_to_many(containers => 'asset_parts', 'asset');

1
