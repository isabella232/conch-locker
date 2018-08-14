use utf8;
package Conch::Locker::DB::Result::Location;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Conch::Locker::DB::Result::Location

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

=head1 TABLE: C<conch_locker.location>

=cut

__PACKAGE__->table("conch_locker.location");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  default_value: uuid_generate_v1mc()
  is_nullable: 0
  size: 16

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 location_type

  data_type: 'text'
  is_nullable: 0

=head2 parent_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 1
  size: 16

=head2 data_center_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 1
  size: 16

=head2 vendor_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 1
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
  "name",
  { data_type => "text", is_nullable => 0 },
  "location_type",
  { data_type => "text", is_nullable => 0 },
  "parent_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 1, size => 16 },
  "data_center_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 1, size => 16 },
  "vendor_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 1, size => 16 },
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

=head2 assets

Type: has_many

Related object: L<Conch::Locker::DB::Result::Asset>

=cut

__PACKAGE__->has_many(
  "assets",
  "Conch::Locker::DB::Result::Asset",
  { "foreign.location_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 data_center

Type: belongs_to

Related object: L<Conch::Locker::DB::Result::Location>

=cut

__PACKAGE__->belongs_to(
  "data_center",
  "Conch::Locker::DB::Result::Location",
  { id => "data_center_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 location_data_centers

Type: has_many

Related object: L<Conch::Locker::DB::Result::Location>

=cut

__PACKAGE__->has_many(
  "location_data_centers",
  "Conch::Locker::DB::Result::Location",
  { "foreign.data_center_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 location_parents

Type: has_many

Related object: L<Conch::Locker::DB::Result::Location>

=cut

__PACKAGE__->has_many(
  "location_parents",
  "Conch::Locker::DB::Result::Location",
  { "foreign.parent_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent

Type: belongs_to

Related object: L<Conch::Locker::DB::Result::Location>

=cut

__PACKAGE__->belongs_to(
  "parent",
  "Conch::Locker::DB::Result::Location",
  { id => "parent_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 vendor

Type: belongs_to

Related object: L<Conch::Locker::DB::Result::Vendor>

=cut

__PACKAGE__->belongs_to(
  "vendor",
  "Conch::Locker::DB::Result::Vendor",
  { id => "vendor_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-14 19:55:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2mBRp1+t5Pl8Fw/tyzC/vw

1;
