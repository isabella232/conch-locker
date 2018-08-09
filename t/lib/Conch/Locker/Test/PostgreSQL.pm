package Conch::Locker::Test::PostgreSQL;
use 5.26.0;
use warnings;
use App::Sqitch;

use Mojo::Base -base, -signatures;
use DBI;
use Test::PostgreSQL;
use DateTime;
use Conch::Locker::DB;
use App::Sqitch::Command::deploy;

has db  => sub ($self) { Test::PostgreSQL->new };
has dsn => sub ($self) { $self->db->dsn };

has dbh => sub ($self) {
    DBI->connect(
        $self->dsn,
        undef, undef,
        {
            pg_enable_utf8 => 1,
            RaiseError     => 1,
            AutoCommit     => 1,
        }
    );
};

has dbic => sub ($self) {
    Conch::Locker::DB->connect(
        {
            dbh_maker   => sub { $self->dbh },
            quote_names => 1,
        }
    );
};

has sqitch => sub ($self) {
    App::Sqitch->new(
        options => {
            engine => 'pg',
        },
    );
};

=for fixtures

has fixtures => sub ($self) {
    Conch::Locker::Test::Fixtures->new( { schema => $_[0]->dbic } );
};

has perm_fixtures => sub ($self) {
    Conch::Locker::Test::Fixtures->new(
        {
            schema          => $_[0]->dbic,
            no_transactions => 1,
        }
    );
};

=cut

sub deploy ($self) {
    my $deploy = App::Sqitch::Command::deploy->new(
        sqitch => $self->sqitch,
        target => $self->db->uri,
    );

    $deploy->execute;
}

1;
__END__
