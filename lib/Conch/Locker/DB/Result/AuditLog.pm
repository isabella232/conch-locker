use utf8;
package Conch::Locker::DB::Result::AuditLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Conch::Locker::DB::Result::AuditLog

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

=head1 TABLE: C<conch_locker.audit_log>

=cut

__PACKAGE__->table("conch_locker.audit_log");

=head1 ACCESSORS

=head2 uuid

  data_type: 'uuid'
  default_value: uuid_generate_v1mc()
  is_nullable: 0
  size: 16

=head2 created

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 user_account

  data_type: 'text'
  default_value: "current_user"()
  is_nullable: 0

=head2 action

  data_type: 'text'
  is_nullable: 0

=head2 table_schema

  data_type: 'text'
  is_nullable: 0

=head2 table_name

  data_type: 'text'
  is_nullable: 0

=head2 old_row

  data_type: 'jsonb'
  is_nullable: 1

=head2 new_row

  data_type: 'jsonb'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "uuid",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v1mc()",
    is_nullable => 0,
    size => 16,
  },
  "created",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "user_account",
  {
    data_type     => "text",
    default_value => \"\"current_user\"()",
    is_nullable   => 0,
  },
  "action",
  { data_type => "text", is_nullable => 0 },
  "table_schema",
  { data_type => "text", is_nullable => 0 },
  "table_name",
  { data_type => "text", is_nullable => 0 },
  "old_row",
  { data_type => "jsonb", is_nullable => 1 },
  "new_row",
  { data_type => "jsonb", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</uuid>

=back

=cut

__PACKAGE__->set_primary_key("uuid");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-09 03:27:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MKmMDZrWbgi1d9lrOv25Mg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
