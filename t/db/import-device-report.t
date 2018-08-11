#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Test::More;
use Test::Fatal;
use Conch::Locker::Test::PostgreSQL;
use Path::Tiny qw(path);
use Mojo::JSON qw(decode_json);

my $db = Conch::Locker::Test::PostgreSQL->new;

is exception { $db->deploy }, undef, 'database set up';

my $schema = $db->dbic;
ok $schema->can('import_device_report');

my $data = decode_json path("t/_assets/device_report.json")->slurp_utf8;
is exception {  $schema->import_device_report($data) }, undef, 'imported device cleanly';

my @assets = $schema->resultset('Asset')->all;
ok @assets > 0, 'more than 0 aseets';

my @parts = $schema->resultset('Part')->all;
ok @parts > 0, 'more than 0 parts too';
ok @parts < @assets, "more assets than parts";

my $server = $schema->resultset('Asset')->search({asset_type => 'server'})->first;
my @components = $server->components;
ok @components > 0, 'got components';
ok @components == @parts, 'same number of components as parts';

done_testing();
