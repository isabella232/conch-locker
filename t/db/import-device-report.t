#!/usr/bin/env perl
use 5.26.0;
use warnings;
use lib qw(t/lib);

use Test::More;
use Test::Fatal;
use Conch::Locker::Test::PostgreSQL;
use Path::Tiny qw(path);
use Mojo::JSON qw(decode_json);

my $db = Conch::Locker::Test::PostgreSQL->new;

is exception { $db->deploy }, undef, 'database set up';

my $schema = $db->dbic;
ok $schema->can('import_device_report');

my $data = decode_json path("t/_assets/device_report.json")->slurp_utf8;
is exception {  $schema->import_device_report($data) }, undef, 'imported device cleanly';
<STDIN>;
done_testing();
