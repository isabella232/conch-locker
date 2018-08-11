#!/usr/bin/env perl
use 5.26.0;
use warnings;
use experimental 'signatures';

use Test::Mojo;
use Test::More;
use Path::Tiny qw(path);
use Mojo::JSON qw(decode_json);

my $app = require "./bin/app.pl";

my $device_type = 'application/vnd.joyent.conch-device-report+json';
my $device_report = decode_json path('./t/_assets/device_report.json')->slurp_utf8;

my $t = Test::Mojo->new;
$t->post_ok( '/conch/import', json => {} )->status_is(415);
$t->post_ok( '/conch/import', { 'Content-Type' => $device_type }, json => {} )->status_is(400);
$t->post_ok( '/conch/import', { 'Content-Type' => $device_type }, json => $device_report )->status_is(204);

done_testing();
