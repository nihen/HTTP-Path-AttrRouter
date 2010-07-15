package HTTP::Path::AttrRouter::Action;
use Any::Moose;

our $VERSION = '0.01';

extends 'Path::AttrRouter::Action';

no Any::Moose;

sub match_method {
    my ($self, $method) = @_;

    return 1 unless $method;

    for my $attribute_method ( @{$self->attributes->{Method} || ['GET', 'HEAD']} ) {
        return 1 if $method eq $attribute_method;
    }
}

__PACKAGE__->meta->make_immutable;
