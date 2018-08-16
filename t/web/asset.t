#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Conch::Locker::Test::PostgreSQL;
use Mojo::JSON qw(decode_json);
use Mojo::File qw(path);
use Test::Mojo;
use Test::More;

my $db = Conch::Locker::Test::PostgreSQL->new;
$db->deploy;

my @assets = map { $_->basename('.json') =~ /conch-device/ }
  path('./t/_assets/')->list->each;

my $dbic = $db->dbic;
$dbic->import_conch_device($_) for @assets;

my $t = Test::Mojo->new( path('./bin/app.pl') );
$t->app->config->{dsn} = $db->dsn;
my $jwt = $t->app->jwt->encode;

my $uuid = $assets[0]->{system_uuid};

$t->get_ok( "/asset/$uuid", { Authorization => "Bearer $jwt" } )
  ->status_is(200)->json_has( '/_links', 'has links' )
  ->json_has( '/_embedded/components', 'has components' )
  ->json_has( '/metadata',             'has metadata' );

done_testing();
