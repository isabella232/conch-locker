#!/usr/bin/env perl
use 5.26.0;
use warnings;
use experimental 'signatures';

use Test::Mojo;
use Test::More;

use FindBin;
require "$FindBin::Bin/../../bin/app.pl"; # import the Mojolicious::Lite app

my $t = Test::Mojo->new;
$t->post_ok('/conch/import', json => { } )->status_is(200);

 done_testing();
