package HTTP::Path::AttrRouter::Controller;
use Any::Moose;

our $VERSION = '0.01';

extends 'Path::AttrRouter::Controller';

no Any::Moose;

sub _parse_Method_attr {
    my ($self, $name, $value) = @_;
    return Method => uc $value;
}

__PACKAGE__->meta->make_immutable;
