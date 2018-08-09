#!/usr/bin/env perl
use 5.26.0;
use autodie ':all';

use lib 'lib';

use App::Sqitch;
use App::Sqitch::Command::deploy;
use App::Sqitch::Command::verify;
use Test::PostgreSQL;

my $db = Test::PostgreSQL->new;

my $sqitch = App::Sqitch->new(
    options => {
        engine => 'pg',
    },
);

my $deploy = App::Sqitch::Command::deploy->new(
    sqitch => $sqitch,
    target => $db->uri,
);

$deploy->execute();

say $db->dsn;
my $dsn = $db->dsn;

$dsn =~ s/^dbi/dbi/i;
$dsn =~ s/dbname\=/database=/i;

use DBIx::Class::Schema::Loader qw/ make_schema_at /;
make_schema_at(
    'Conch::Locker::DB',
    {
        debug                   => 1,
        qualify_objects         => 1,
        overwrite_modifications => 1,
        dump_directory          => './lib',
        db_schema               => 'conch_locker',
        components              => [
            qw(
              Helper::Row::ToJSON
              +Conch::Locker::DB::InflateColumn::JSON
              )
        ],
    },
    [$dsn],
);

