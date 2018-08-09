use utf8;
package Conch::Locker::DB::Result::AssetPart;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Conch::Locker::DB::Result::AssetPart

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

=head1 TABLE: C<conch_locker.asset_part>

=cut

__PACKAGE__->table("conch_locker.asset_part");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  default_value: uuid_generate_v1mc()
  is_nullable: 0
  size: 16

=head2 asset_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 part_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 audit_id

  data_type: 'uuid'
  is_nullable: 0
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
  "asset_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "part_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "audit_id",
  { data_type => "uuid", is_nullable => 0, size => 16 },
  "metadata",
  { data_type => "jsonb", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

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

=head2 part

Type: belongs_to

Related object: L<Conch::Locker::DB::Result::Part>

=cut

__PACKAGE__->belongs_to(
  "part",
  "Conch::Locker::DB::Result::Part",
  { id => "part_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-09 03:27:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SzrDq3MUp3OxgORdFaauvg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
