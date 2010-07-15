package HTTP::Path::AttrRouter::DispatchType::Chained;
use Any::Moose;

our $VERSION = '0.01';

extends 'Path::AttrRouter::DispatchType::Chained';

around match => sub {
    my ($orig, $self, $path, $method, $args, $captures, $action_class) = @_;
    return if @$args;

    my @parts = split '/', $path;

    my ($chain, $action_captures, $parts) = $self->recurse_match($method, '/', @parts);
    return unless $chain;

    @$args = @$parts;
    @$captures = @$action_captures;

    return $action_class->from_chain($chain);
};

around recurse_match => sub {
    my ($orig, $self, $method, $parent, @pathparts) = @_;

    my @chains = @{ $self->chain_from->{ $parent } || [] }
        or return;

    for my $action (@chains) {
        my @parts = @pathparts;

        my $pathpart = $action->attributes->{PathPart}[0];
        if (length $pathpart) {
            my @p = split '/', $pathpart;
            next if @p > @parts;

            my @stripped = splice @parts, 0, scalar @p;
            next unless $pathpart eq join '/', @stripped;
        }

        if (defined $action->attributes->{CaptureArgs}[0]) {
            my $capture_args = $action->attributes->{CaptureArgs}[0];
            next if @parts < $capture_args;

            my @captures = splice @parts, 0, $capture_args;
            my ($actions, $captures, $action_parts)
                = $self->recurse_match($method, '/'.$action->reverse, @parts);
            next unless $actions;

            return ([ $action, @$actions ], [@captures, @$captures], $action_parts);
        }
        else {
            next unless $action->match_method($method);
            next unless $action->match_args(\@parts);
            return ([ $action ], [], \@parts);
        }
    }
};

no Any::Moose;

__PACKAGE__->meta->make_immutable;

