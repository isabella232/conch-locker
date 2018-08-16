#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Conch::Locker::Test::PostgreSQL;
use Mojo::JSON qw(decode_json);
use Mojo::File qw(path);
use Test::Mojo;
use Test::More;

my $device_data = decode_json path('./t/_assets/conch-device-server.json')->slurp;

my $db = Conch::Locker::Test::PostgreSQL->new;
$db->deploy;
$db->dbic->import_conch_device($device_data);    # load up the data

my $t = Test::Mojo->new( path('./bin/app.pl') );
$t->app->config->{dsn} = $db->dsn;
my $jwt = $t->app->jwt->encode;

my $uuid = $device_data->{system_uuid};

$t->get_ok( "/asset/$uuid", { Authorization => "Bearer $jwt" } )
  ->status_is(200);

done_testing();
