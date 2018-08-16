#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Test::More;
use Test::Fatal;
use Conch::Locker::Test::PostgreSQL;
use Mojo::File qw(path);
use Mojo::JSON qw(decode_json);

my $db = Conch::Locker::Test::PostgreSQL->new;

is exception { $db->deploy }, undef, 'database set up';

my $schema = $db->dbic;
ok $schema->can('import_conch_device');

{
    diag "Loading a server";
    my $data = decode_json path("t/_assets/conch-device-server.json")->slurp;
    is exception { $schema->import_conch_device($data) }, undef,
      'imported device cleanly';

    my $assets = $schema->resultset('Asset')->count;
    ok $assets > 0, 'more than 0 aseets';

    my $parts = $schema->resultset('Part')->count;
    ok $parts > 0, 'more than 0 parts too';
    ok $parts < $assets, "more assets than parts";

    my $server =
      $schema->resultset('Asset')->search( { asset_type => 'server' } )->first;
    my $components = $server->components->count;
    ok $components > 0, 'got components';
    is $components, $parts, 'same number of components as parts';
}

{
    diag "loading a switch";
    my $data = decode_json path("t/_assets/conch-device-switch.json")->slurp;
    is exception { $schema->import_conch_device($data) }, undef,
      'imported device cleanly';

    my $assets = $schema->resultset('Asset')->count;
    ok $assets > 0, 'more than 0 aseets';

    my $parts = $schema->resultset('Part')->count;
    ok $parts > 0, 'more than 0 parts too';

    my $server =
      $schema->resultset('Asset')->search( { asset_type => 'switch' } )->first;
    my $components = $server->components->count;
    ok $components > 0, 'got components';
    is $components,  2, 'same number of components as psus';
}

done_testing();
