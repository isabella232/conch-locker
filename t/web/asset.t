#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Conch::Locker::Test::PostgreSQL;
use Mojo::JSON qw(decode_json);
use Mojo::File qw(path);
use Test::Mojo;
use Test::More;

my $device_report = decode_json path('./t/_assets/device_report.json')->slurp;

my $db = Conch::Locker::Test::PostgreSQL->new;
$db->deploy;
$db->dbic->import_device_report($device_report);    # load up the data

my $t = Test::Mojo->new( path('./bin/app.pl') );

my $uuid = $device_report->{system_uuid};

$t->get_ok("/asset/$uuid")->status_is(200);

done_testing();
