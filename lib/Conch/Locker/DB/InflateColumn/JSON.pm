package Conch::Locker::DB::InflateColumn::JSON;
use 5.26.0;
use experimental 'signatures';

use parent qw/DBIx::Class/;
use Mojo::JSON qw(decode_json encode_json);
use Storable;

__PACKAGE__->load_components(qw/InflateColumn/);

sub register_column ( $self, $column, $info, @rest ) {
    $self->next::method( $column, $info, @rest );

    my $data_type = lc( $info->{data_type} || '' );
    return unless $data_type eq 'jsonb';

    $self->inflate_column(
        $column => {
            inflate => sub ( $value, $obj ) {
                decode_json($value);
            },
            deflate => sub ( $value, $obj ) {
                $value = Storable::dclone $value;
                encode_json($value);
            },
        }
    );
}

1;
__END__
