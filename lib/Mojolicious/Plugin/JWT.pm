package Mojolicious::Plugin::JWT;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::JWT;
use Try::Tiny;

sub register {
    my ( $plugin, $app, $conf ) = @_;

    $app->helper(
        jwt => sub {
            my ( $c, $claims, $exp ) = @_;
            Mojo::JWT->new(
                secret  => $c->app->secrets->[0],
                claims  => $claims // {},
                expires => $exp,
                set_iat => 1,
            );
        }
    );

    $app->helper(
        validate_jwt => sub {
            my ( $c, $token ) = @_;
            return unless $token;
            try {
                $c->jwt->decode($token);
                return 1
            }
            catch {
                $c->app->log->error($_);
                return;
            }
        }
    );

    $app->helper(
        bearer_token => sub {
            my ($c) = @_;
            return unless $c->req->headers->authorization;
            return unless $c->req->headers->authorization =~ /^Bearer (.+)/;
            return $1;
        }
    );
}

1;
__END__
