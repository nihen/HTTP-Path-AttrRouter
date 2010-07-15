package HTTP::Path::AttrRouter::DispatchType::Regex;
use Any::Moose;

our $VERSION = '0.01';

extends 'Path::AttrRouter::DispatchType::Regex';

around match => sub {
    my ($orig, $self, $path, $method, $args, $captures) = @_;

    for my $compiled (@{ $self->compiled }) {
        next unless $compiled->{action}->match_method($method);
        if (my @captures = ($path =~ $compiled->{re})) {
            @$captures = @captures;
            return $compiled->{action};
        }
    }

    return;
};

no Any::Moose;

__PACKAGE__->meta->make_immutable;

