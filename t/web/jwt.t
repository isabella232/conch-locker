#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Mojo::File qw(path);
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new(path('./bin/app.pl'));

$t->post_ok('/me/tokens')->status_is(401);

my $jwt = $t->app->jwt->encode;

$t->post_ok('/me/tokens', { Authorization => "Bearer $jwt" })->status_is(201);

done_testing();
