#!/usr/bin/env perl
use 5.26.0;
use experimental 'signatures';

use Conch::Locker::DB;
use HAL::Tiny;
use JSON::Validator;
use Mojolicious::Lite;
use Try::Tiny;

app->types->type(
    device_report => 'application/vnd.joyent.conch-device-report+json' );

plugin 'Config' => {
    default => {
        dsn => 'dbi:Pg:database=conch-locker',
    },
};

helper validator_for => sub ( $c, $schema_loc ) {
    my $schema = app->home->child( 'json-schema' => $schema_loc )->slurp;
    my $validator = JSON::Validator->new;
    $validator->load_and_validate_schema($schema);
    return $validator;
};

helper valid_input => sub ( $c, $schema_file ) {
    my $validator = $c->validator_for($schema_file);
    my $json      = $c->req->json;
    if ( my @errors = $validator->validate($json) ) {
        $c->log->error( 'FAILED json validation for $schema_file: ' . join '//',
            @errors );
        $c->status( 400, { error => join( "\n", @errors ) } );
        return;
    }
    return $json;
};

helper schema => sub ($c) {
    Conch::Locker::DB->connect( app->config->{dsn} );
};

post '/conch/import' => sub ($c) {
    $c->respond_to(
        device_report => sub {
            my $schema = 'device-report.schema.json';
            if ( my $input = $c->valid_input($schema) ) {
                $c->log->info('importing detailed device');
                try {
                    $c->schema->import_device_report($input);
                }
                catch {
                    $c->status( 500, { error => $_ } );
                };
                $c->status(204);
            }
            return;
        },
        any => { status => 415 },
    );
};

app->start;
