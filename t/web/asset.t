#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Conch::Locker::Test::PostgreSQL;
use Mojo::JSON qw(decode_json);
use Path::Tiny qw(path);
use Test::Mojo;
use Test::More;


my $device_report =
  decode_json path('./t/_assets/device_report.json')->slurp_utf8;

my $db = Conch::Locker::Test::PostgreSQL->new;
$db->deploy;
$db->dbic->import_device_report($device_report);    # load up the data

my $app = "./bin/app.pl";
require $app // BAIL_OUT "Couldn't load $app";
my $t = Test::Mojo->new( Mojo::Server->new->load_app($app) );
$t->app->config->{dsn} = $db->dsn;

my $uuid = $device_report->{system_uuid};

use DDP;
p $t->get_ok("/asset/$uuid")->status_is(200)->tx->res->json;;

done_testing();
