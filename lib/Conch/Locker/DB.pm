use utf8;
package Conch::Locker::DB;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-07 22:34:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ypejI5LNH4m35r+yTkRAgw
use 5.26.0;
use experimental 'signatures';

sub add_asset ( $self, $data ) {
    $self->resultset('Asset')->update_or_create($data);
}

sub add_part ( $self, $data ) {
    my $asset = $self->add_asset($data);
    delete $data->{asset_type};
    $data->{asset_id} = $asset->id;
    $self->resultset('Part')->update_or_create($data);
}

sub import_device_report ( $self, $data ) {

    my $asset = $self->add_asset(
        {
            id            => $data->{system_uuid},
            name          => $data->{product_name},
            asset_type    => 'server',
            serial_number => $data->{serial_number},
            metadata      => {
                bios_version  => $data->{bios_version},
                latest_report => $data->{report_id},
                state         => $data->{state},
                temp          => $data->{temp},
                uptime_since  => $data->{uptime_since},
                sku           => $data->{sku},
            },
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
                    name          => $nic->{product},
                    serial_number => $nic->{mac},
                    metadata      => $nic,
                }
            )
        );
    }
}

1;
