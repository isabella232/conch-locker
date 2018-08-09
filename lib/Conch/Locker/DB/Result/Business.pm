use utf8;
package Conch::Locker::DB::Result::Business;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Conch::Locker::DB::Result::Business

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

=head1 TABLE: C<conch_locker.business>

=cut

__PACKAGE__->table("conch_locker.business");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  default_value: uuid_generate_v1mc()
  is_nullable: 0
  size: 16

=head2 name

  data_type: 'text'
  is_nullable: 0

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-09 03:27:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+fnomWUT4j44TVjgYjN53A

1;
