package HTTP::Path::AttrRouter::Action;
use Any::Moose;

our $VERSION = '0.01';

extends 'Path::AttrRouter::Action';

around match => sub {
    my ($orig, $self, $condition) = @_;

    return 0 unless $self->$orig($condition);
    return 0 unless $self->match_method($condition->{method});

    return 1;
};

no Any::Moose;

sub match_method {
    my ($self, $method) = @_;

    return 1 unless $method;

    for my $attribute_method ( @{$self->attributes->{Method} || ['GET', 'HEAD']} ) {
        return 1 if $method eq $attribute_method;
    }
}

__PACKAGE__->meta->make_immutable;
