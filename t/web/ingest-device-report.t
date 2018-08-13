#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Conch::Locker::Test::PostgreSQL;
use Mojo::JSON qw(decode_json);
use Mojo::File qw(path);
use Test::Mojo;
use Test::More;

my $device_type   = 'application/vnd.joyent.conch-device-report+json';
my $device_report = decode_json path('./t/_assets/device_report.json')->slurp;

my $db = Conch::Locker::Test::PostgreSQL->new;
$db->deploy;

my $t = Test::Mojo->new( path('./bin/app.pl') );
$t->app->config->{dsn} = $db->dsn;
my $jwt = $t->app->jwt->encode;

# try give it an unsupported medai type (plain application/json)
$t->post_ok( '/conch/import', { Authorization => "Bearer $jwt" }, json => {} )
  ->status_is(415);

# give it a valid media type with an invalid document
$t->post_ok(
    '/conch/import',
    {
        'Content-Type' => $device_type,
        Authorization  => "Bearer $jwt"
    },
    json => {}
)->status_is(400)->json_like( '/error' => qr/Missing property/ );

# give it a valid request now
$t->post_ok(
    '/conch/import',
    {
        'Content-Type' => $device_type,
        Authorization  => "Bearer $jwt"
    },
    json => $device_report
)->status_is(204);

# and make sure everything ended up where it belongs
my $schema = $db->dbic;

my $server =
  $schema->resultset('Asset')->search( { asset_type => 'server' } )->first;
ok $server->components->count > 0, 'got components';

done_testing();
