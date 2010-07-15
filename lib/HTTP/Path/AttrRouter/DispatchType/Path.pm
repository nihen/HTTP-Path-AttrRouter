package HTTP::Path::AttrRouter::DispatchType::Path;
use Any::Moose;

extends 'Path::AttrRouter::DispatchType::Path';

around list => sub {
    my ($orig, $self) = @_;
    return unless $self->used;

    my @rows = [[ 1 => 'Path'], [1 => 'Method'], [ 1 => 'Private' ]];

    for my $path (sort keys %{ $self->paths }) {
        for my $action (@{ $self->paths->{ $path } }) {
            my $display_path = $path eq '/' ? '' : "/$path";

            if (defined $action->num_args) {
                $display_path .= '/*' for 1 .. $action->num_args;
            }
            else {
                $display_path .= '/...';
            }

            push @rows, [ $display_path || '/', (join ',', @{$action->attributes->{Method} || ['GET', 'HEAD']}), '/' . $action->reverse ];
        }
    }

    return \@rows;
};

no Any::Moose;
__PACKAGE__->meta->make_immutable;
