#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Conch::Locker::Test::PostgreSQL;
use Mojo::JSON qw(decode_json);
use Mojo::File qw(path);
use Test::Mojo;
use Test::More;

my $db = Conch::Locker::Test::PostgreSQL->new->deploy;

my @assets = grep {
         $_->basename('.json') =~ /conch-device/
      && $_->basename('.json') !~ /switch/;
} path('./t/_assets/')->list->each;

$db->dbic->import_conch_device($_) for map { decode_json $_->slurp } @assets;

my $t = Test::Mojo->new( path('./bin/app.pl') );
$t->app->config->{dsn} = $db->dsn;
my $jwt = $t->app->jwt->encode;

my $headers = { Authorization => "Bearer $jwt" };

my $data = decode_json( $assets[0]->slurp );
my $uuid = $data->{system_uuid};
my $location = $data->{location}{datacenter}{name};

$t->get_ok( "/asset/$uuid", $headers )->status_is(200)
  ->json_has( '/_links',               'has links' )
  ->json_has( '/_embedded/components', 'has components' )
  ->json_has( '/metadata',             'has metadata' );

# "How many servers are deployed in all regions?"
$t->get_ok( "/asset?type=server", $headers )->status_is(200)
  ->json_has( '/_embedded/assets', 'has asset list' )
  ->json_is( '/total', scalar @assets );

# "How many assets are in us-east-1?"
$t->get_ok( "/asset?location=$location", $headers )->status_is(200)
  ->json_has( '/_embedded/assets', 'has asset list' )
  ->json_like( '/total', qr/\d+/);

{
    # "How many servers are in us-east-1?"
    my $data =
      $t->get_ok( "/asset?type=server&location=$location", $headers )
      ->status_is(200)->json_has( '/_embedded/assets', 'has asset list' )
      ->tx->res->json;

    ok $data->{total} > 0, 'got more than 0 devices';
    ok grep( { $_->{id} = $uuid } $data->{_embedded}{assets}->@*), 'one of the devices is the one we expect';
}
{
    # "How many hard drives of x type are in eu-central-1?"
    my $data =
      $t->get_ok( "/asset?type=disk&location=$location&model=HUH721212AL4200", $headers )
      ->status_is(200)->json_has( '/_embedded/assets', 'has asset list' )
      ->tx->res->json;

    ok $data->{total} > 0, 'got more than 0 devices';
}

done_testing();
