#!/usr/bin/env perl
use 5.26.0;
use Mojolicious::Lite -signatures;
use lib qw(lib);

use Conch::Locker::DB;
use HAL::Tiny;
use JSON::Validator;
use Try::Tiny;

app->types->type(
    device_report => 'application/vnd.joyent.conch-device-report+json' );

plugin 'Config' => {
    default => {
        dsn     => $ENV{CONCH_LOCKER_DSN} // 'dbi:Pg:database=conch-locker',
        secrets => [ $ENV{CONCH_LOCKER_SECRET} // 'abcde' ],
    },
};

plugin 'RespondFor';
plugin 'JWT';

helper validator_for => sub ( $c, $schema_loc ) {
    my $schema = app->home->child( '../json-schema' => $schema_loc )->slurp;
    my $validator = JSON::Validator->new;
    $validator->load_and_validate_schema($schema);
    return $validator;
};

helper valid_input => sub ( $c, $schema_file ) {
    my $validator = $c->validator_for($schema_file);
    my $json      = $c->req->json;
    if ( my @errors = $validator->validate($json) ) {
        $c->app->log->error(
            "FAILED json validation for $schema_file:\n" . join "\n", @errors );
        $c->render( status => 400, json => { error => join( "\n", @errors ) } );
        return;
    }
    return $json;
};

helper schema => sub ($c) {
    Conch::Locker::DB->connect( app->config->{dsn} );
};

under sub ($c) {
    return 1 if $c->validate_jwt( $c->bearer_token );
    $c->rendered(401) && return;
};

post '/me/tokens' => sub  ($c) {
    $c->render(
        status => 201,
        json   => { token => $c->jwt->encode() }
    );
};

post '/conch/import' => sub ($c) {
    $c->respond_for(
        device_report => sub {
            my $schema = 'device-report.schema.json';
            if ( my $input = $c->valid_input($schema) ) {
                $c->app->log->info('importing detailed device');
                try {
                    $c->schema->import_device_report($input);
                    $c->rendered(204);
                }
                catch {
                    $c->app->log->error("Couldn't import report: $_");
                    $c->render( status => 500, json => { error => $_ } );
                };
            }
            return;
        },
    );
};

get '/asset/:uuid' => sub ($c) {
    my $uuid = $c->param('uuid');
    if ( my $asset = $c->schema->find_asset($uuid) ) {
        $c->render( json => $asset );
        return;
    }
    $c->rendered(404);
};

# set up the secrets
app->secrets(app->config->{secrets});
app->start;
