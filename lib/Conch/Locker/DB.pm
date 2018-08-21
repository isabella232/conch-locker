use utf8;

package Conch::Locker::DB;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-14 19:55:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TUF+x4BlE169nk9DBhUpyA
use 5.26.0;
use experimental 'signatures';

sub find_asset_by_id ( $self, $uuid ) {
    $self->resultset('Asset')->search(
        { id => $uuid },
        {
            join => 'audit_log',
        }
    )->first;
}

sub add_asset ( $self, $data ) {
    $self->resultset('Asset')->update_or_create($data);
}

sub add_part ( $self, $data ) {
    my $asset = $self->add_asset($data);
    delete $data->{asset_type};
    delete $data->{location_id};
    $data->{asset_id} = $asset->id;
    $self->resultset('Part')->update_or_create($data);
}

sub add_location ( $self, $data ) {
    $self->resultset('Location')->update_or_create($data);
}

sub import_conch_device ( $self, $data ) {
    die "data isn't reference" unless ref $data;


    my $dc = $data->{location}{datacenter};
    $self->add_location(
        {
            id            => $dc->{id},
            name          => $dc->{name},
            location_type => 'datacenter',
            metadata      => $dc,
        }
    );

    my $rack_data     = $data->{location}{rack};
    my $rack_location = $self->add_location(
        {
            id             => $rack_data->{id},
            name           => $rack_data->{name},
            location_type  => 'rack',
            parent_id      => $dc->{id},
            data_center_id => $dc->{id},
            metadata       => $rack_data,
        }
    );

    $self->add_asset(
        {
            name          => $rack_data->{name},
            asset_type    => 'rack',
            location_id   => $rack_data->{id},
            serial_number => $rack_data->{id},
            metadata      => $rack_data,
        }
    );

    my $asset = $self->import_device_report( $data->{latest_report}, $rack_location );

    return $asset;
}

sub import_device_report ( $self, $data, $location = undef ) {

    my $asset = $self->add_asset(
        {
            id            => $data->{system_uuid},
            name          => $data->{product_name},
            asset_type    => $data->{device_type} // 'server',
            serial_number => $data->{serial_number},
            $location ? ( location_id => $location->id ) : (),
            metadata => {
                bios_version  => $data->{bios_version},
                latest_report => $data->{report_id},
                state         => $data->{state},
                temp          => $data->{temp},
                uptime_since  => $data->{uptime_since},
                sku           => $data->{sku},
            },
        }
    );

    my $asset_location = $self->add_location(
        {
            id            => $asset->id,
            name          => $asset->name,
            location_type => $asset->asset_type,
            $asset->location ? ( parent_id => $asset->location->id ) : (),
            data_center_id => $asset->location->data_center_id,
        }
    );

    # CPUs
    #    for my $cpu ( $data->{cpus}->@* ) {
    #        $asset->add_to_components(
    #            type     => 'cpu',
    #            metadata => $cpu
    #        );
    #    }

    # DIMMs
    for my $dimm ( $data->{dimms}->@* ) {
        my $serial_number = delete $dimm->{'memory-serial-number'}
          // next;    # no serial number, not dimm

        my $name = join ' ',
          $dimm->@{qw( memory-manufacturer memory-part-number )};

        $asset->add_to_components(
            $self->add_part(
                {
                    asset_type    => 'dimm',
                    location_id   => $asset_location->id,
                    name          => $name,
                    serial_number => $serial_number,
                    metadata      => $dimm,
                }
            )
        );
    }

    # Disks
    for my $sn ( keys $data->{disks}->%* ) {
        my $disk = $data->{disks}{$sn};
        my $name = join ' ', grep $disk->@{
            qw(
              vendor
              drive_type
              model
              )
        };

        $asset->add_to_components(
            $self->add_part(
                {
                    asset_type    => 'disk',
                    location_id   => $asset_location->id,
                    name          => $name,
                    serial_number => $sn,
                    metadata      => $disk,
                }
            )
        );
    }

    # HBA
    #for my $controller ( keys $data->{hba}->%* ) {
    #    my $hba = $data->{hba}{$controller};
    #    $asset->add_to_components(
    #        $self->add_part(
    #            {
    #                name     => "HBA $hba->{type}",
    #                asset_type     => 'hba',
    #                location_id   => $asset_location->id,
    #                metadata => $hba,
    #            }
    #        )
    #    );
    #}

    # Interfaces
    for my $iface ( keys $data->{interfaces}->%* ) {
        my $nic = $data->{interfaces}{$iface};
        $nic->{interface} = $iface;

        $asset->add_to_components(
            $self->add_part(
                {
                    asset_type    => 'nic',
                    location_id   => $asset_location->id,
                    name          => $nic->{product},
                    serial_number => $nic->{mac},
                    metadata      => $nic,
                }
            )
        );
    }

    for my $psu ( $data->{psus}{units}->@* ) {
        $asset->add_to_components(
            $self->add_part(
                {
                    asset_type    => 'psu',
                    location_id   => $asset_location->id,
                    name          => $psu->{serial},
                    serial_number => $psu->{serial},
                    metadata      => $psu
                }
            )
        );
    }

    return $asset;
}

1;
