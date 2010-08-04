package HTTP::Path::AttrRouter;
use Any::Moose;

our $VERSION = '0.01';

extends 'Path::AttrRouter';

has '+action_class' => (
    default => 'HTTP::Path::AttrRouter::Action',
);

has '+dispatch_types' => (
    default => sub {
        my $self = shift;

        my @types;
        for (qw/Path Regex Chained/) {
            my $class = "HTTP::Path::AttrRouter::DispatchType::$_";
            $self->_ensure_class_loaded($class);
            push @types, $class->new;
        }

        \@types;
    },
);


around match => sub {
    my ($orig, $self, $path, $method) = @_;

    return $self->$orig($path, {method => $method});
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
