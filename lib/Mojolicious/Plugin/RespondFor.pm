package Mojolicious::Plugin::RespondFor;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
    my ( $plugin, $app, $conf ) = @_;
    $app->helper(
        respond_for => sub {
            my $c = shift;

            die "must supply actions" unless @_;
            my $actions = ( @_ == 1 ) ? shift : {@_};

            $actions->{none} //= sub {
                shift->render(
                    data   => '',
                    status => 415,
                );
                return 0;
            };

            my $got = $c->req->headers->content_type;
            $c->app->log->debug("got Content-Type: $got");
            my @types = @{ $c->app->types->detect( $got, 1 ) };
            push @types, qw/any none/;
            $c->app->log->debug("found types: @types");
            for my $type (@types) {
                if ( my $action = $actions->{$type} ) {
                    $c->app->log->debug("dispatching for $type");
                    return $c->$action();
                }
            }
        }
    );
}

1;
__END__

