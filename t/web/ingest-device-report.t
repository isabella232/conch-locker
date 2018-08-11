#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Conch::Locker::Test::PostgreSQL;
use Mojo::JSON qw(decode_json);
use Path::Tiny qw(path);
use Test::Mojo;
use Test::More;

my $app = "./bin/app.pl";
require $app // BAIL_OUT "Couldn't load $app";

my $device_type = 'application/vnd.joyent.conch-device-report+json';
my $device_report =
  decode_json path('./t/_assets/device_report.json')->slurp_utf8;

my $db = Conch::Locker::Test::PostgreSQL->new;
$db->deploy;

my $t = Test::Mojo->new(
    Mojo::Server->new->load_app($app),
    {
        dsn => $db->dsn,
    }
);

$t->post_ok( '/conch/import', json => {} )->status_is(415);

$t->post_ok( '/conch/import', { 'Content-Type' => $device_type }, json => {} )
  ->status_is(400);

$t->post_ok(
    '/conch/import',
    { 'Content-Type' => $device_type },
    json => $device_report
)->status_is(204);

done_testing();
