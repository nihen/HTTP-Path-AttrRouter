package HTTP::Path::AttrRouter::DispatchType::Path;
use Any::Moose;

our $VERSION = '0.01';

extends 'Path::AttrRouter::DispatchType::Path';

around match => sub {
    my ($orig, $self, $path, $method, $args, $captures) = @_;

    $path = '/' if !defined $path || !length $path;

    for my $action (@{ $self->paths->{$path} || [] }) {
        next unless $action->match_method($method);
        return $action if $action->match_args($args);
    }

    return;
};

no Any::Moose;

__PACKAGE__->meta->make_immutable;

