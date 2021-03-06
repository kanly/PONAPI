package PONAPI::Relationship::Builder;
# ABSTRACT: A Perl implementation of the JASON-API (http://jsonapi.org/format) spec - Relationships

use strict;
use warnings;
use Moose;

with qw<
    PONAPI::Role::HasData
    PONAPI::Role::HasMeta
    PONAPI::Role::HasLinks
    PONAPI::Role::HasErrors
>;

sub build {
    my $self = shift;
    my %ret;
   
    if ( $self->has_data ) {
    	if(scalar @{$self->_data}==1) {
    		$ret{data} = $self->_data->[0];
    	} else {
    		$ret{data} = $self->_data;
    	}
    }
    $self->has_meta and $ret{meta} = $self->_meta;

    $self->has_links or $self->has_data or $self->has_meta
        or $self->add_errors( +{
            detail => 'Relationship should contain at least one of "links", "data" or "meta"',
        });

    if ( $self->has_links ) {
        exists $self->_links->{self} or exists $self->_links->{related}
            or $self->add_errors( +{
                detail => 'Relationship links should contain at least one of "self" or "related"',
            });
        $ret{links} = $self->_links;
    }

    if ( $self->has_errors ) {
        return +{
            errors => $self->_errors,
        };
    }

    return \%ret;
}

__PACKAGE__->meta->make_immutable;
1;

__END__
