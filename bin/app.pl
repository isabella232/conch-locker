#!/usr/bin/env perl
use 5.26.0;
use Mojolicious::Lite -signatures;
use lib qw(lib);

use Conch::Locker::DB;
use HAL::Tiny;
use JSON::Validator;
use Try::Tiny;

my %types = (
    conch_device  => 'application/vnd.joyent.conch-device-data+json',
    device_report => 'application/vnd.joyent.conch-device-report+json',
);

app->types->type( $_ => $types{$_} ) for keys %types;

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

helper location => sub ( $c, @parts ) {
    $c->res->headers->location( $c->url_for(@parts) );
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
        conch_device => sub {
            my $schema = 'conch-device.schema.json';
            if ( my $input = $c->valid_input($schema) ) {
                $c->app->log->info('importing device from conch');
                try {
                    my $asset = $c->schema->import_conch_device($input);
                    $c->location("/asset/${\$asset->id}");
                    $c->rendered(204);
                }
                catch {
                    $c->app->log->error("Couldn't import device $_");
                    $c->render( status => 500, json => { error => $_ } );
                };
            }
            return;
        },
        device_report => sub {
            my $schema = 'device-report.schema.json';
            if ( my $input = $c->valid_input($schema) ) {
                $c->app->log->info('importing device report');
                try {
                    my $asset = $c->schema->import_device_report($input);
                    $c->location("/asset/${\$asset->id}");
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
    if ( my $asset = $c->schema->find_asset_by_id($uuid) ) {
        my $hal = HAL::Tiny->new(
            state => $asset->TO_JSON,
            links => {
                self => "/asset/${ \$asset->id }",

                #archives => "/audit/${ \$asset->audit_id }",
            },
            embedded => {
                components => [
                    map {
                        HAL::Tiny->new(
                            state => $_->TO_JSON,
                            links => { self => "/asset/${ \$_->asset->id }" },
                          )
                    } $asset->components->all
                ],
            },
        );
        $c->render( json => $hal->as_hashref );
        return;
    }
    $c->rendered(404);
};

get '/asset' => sub ($c) {
    my $args   = $c->req->params->to_hash;
    my $assets = $c->schema->resultset('Asset');

    if ( my $name = delete $args->{location} ) {
        my $rs = $c->schema->resultset('Location');
        my $dc = $rs->search( { name => $name } )->first;
        unless ($dc) {
            $c->app->log->info("No datacenter found for $name");
            return $c->rendered(404);
        }
        $assets = $assets->search( { 'location.data_center_id' => $dc->id },
            { join => 'location' } );
    }

    # TODO replace this with something more dynamic or less crappy
    my %fields = (
        id            => 'id',
        name          => 'name',
        type          => 'asset_type',
        serial_number => 'serial_number',
    );
    for my $key ( map { lc } keys $args->%* ) {
        if ( my $db_col = $fields{$key} ) {
            $args->{$db_col} = delete $args->{$key};
        }
        else {
            my $value = delete $args->{$key};
            warn $key;
            $args->{'me.metadata'} = \[ ' ->> ' . "'$key' = ?", $value ];
        }
    }
    my $rs = $assets->search($args);
    if ( $rs->count > 0 ) {
        my $hal = HAL::Tiny->new(
            state => {
                total => $rs->count,
            },
            links => {

                #self     => "/asset/${ \$asset->id }",
            },
            embedded => {
                assets => [
                    map {
                        HAL::Tiny->new(
                            state => $_->TO_JSON,
                            links => { self => "/asset/${ \$_->id }" },
                          )
                    } $rs->all
                ],
            },
        );
        $c->render( json => $hal->as_hashref );
    }
    else {
        $c->rendered(404);
    }
};

#get '/audit/:uuid' => sub ($c) {
#    my $uuid = $c->param('uuid');
#    if ( my $part = $c->schema->find_audit($uuid) ) {
#        $c->render( json => $part );
#        return;
#    }
#    $c->rendered(404);
#};

app->secrets( app->config->{secrets} );
app->start;
