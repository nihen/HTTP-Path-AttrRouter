package HTTP::Path::AttrRouter;
use Any::Moose;

our $VERSION = '0.01';

extends 'Path::AttrRouter';

+has action_class => (
    is      => 'rw',
    isa     => 'Str',
    default => 'HTTP::Path::AttrRouter::Action',
);


around match => sub {
    my ($orig, $self, $path, $method) = @_;

    my @path = split m!/!, $path;
    unshift @path, '' unless @path;

    $method = uc $method if $method;

    my ($action, @args, @captures);
 DESCEND:
    while (@path) {
        my $p = join '/', @path;
        $p =~ s!^/!!;

        for my $type (@{ $self->dispatch_types }) {
            $action = $type->match({path => $p, method => $method, args => \@args, captures => \@captures, action_class => $self->action_class});
            last DESCEND if $action;
        }

        my $arg = pop @path;
        $arg =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        unshift @args, $arg;
    }

    s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg
        for grep {defined} @captures;

    if ($action) {
        # recreate controller instance if it is cached object
        unless (ref $action->controller) {
            $action->controller($self->_load_module($action->controller));
        }

        return Path::AttrRouter::Match->new(
            action   => $action,
            args     => \@args,
            captures => \@captures,
            router   => $self,
        );
    }
    return;
};

no Any::Moose;
__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

HTTP::Path::AttrRouter -

=head1 SYNOPSIS

  use HTTP::Path::AttrRouter;

=head1 DESCRIPTION

HTTP::Path::AttrRouter is

=head1 AUTHOR

Masahiro Chiba E<lt>chiba@everqueue.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
