package HTTP::Path::AttrRouter::DispatchType::Chained;
use Any::Moose;

extends 'Path::AttrRouter::DispatchType::Chained';

around list => sub {
    my ($orig, $self) = @_;
    return unless $self->used;

    my @rows = [[ 1 => 'Path Spec'], [1 => 'Method'], [ 1 => 'Private' ]];
    my @unattached;

    for my $endpoint (sort { $a->reverse cmp $b->reverse } @{ $self->endpoints }) {
        my @parts = defined $endpoint->num_args
                    ? ( ('*') x $endpoint->num_args )
                    : ('...');
        my @parents;

        my $cur = $endpoint;
        my $parent;
        while ($cur) {
            if (my $cap = $cur->attributes->{CaptureArgs}) {
                unshift @parts, (('*') x $cap->[0]) if $cap->[0];
            }
            if (my $pp = $cur->attributes->{PathPart}) {
                unshift @parts, $pp->[0]
                    if defined $pp->[0] and length $pp->[0];
            }
            $parent = $cur->attributes->{Chained}[0];
            $cur = $self->actions->{ $parent };

            unshift @parents, $cur if $cur;
        }

        if ($parent ne '/') {
            push @unattached,
                [ '/' . ($parents[0] || $endpoint)->reverse, '', $parent ];
            next;
        }

        my @r;
        for my $parent (@parents) {
            my $name = $parent->reverse eq $parents[0]->reverse
                       ? '/' . $parent->reverse
                       : '-> ' . $parent->reverse;

            if (my $cap = $parent->attributes->{CaptureArgs}) {
                $name .= ' (' . $cap->[0] . ')';
            }

            push @r, [ '',  '', $name ];
        }
        push @r, [ '', '', (@r ? '=> ' : '') . '/' . $endpoint->reverse ];
        $r[0][0] = join('/', '', @parts) || '/';
        $r[0][1] = join ',', @{$endpoint->attributes->{Method} || ['GET', 'HEAD']};

        push @rows, @r;
    }

    if (@unattached) {
        push @rows, undef;
        push @rows, ['Private', '', 'Missing parent'];
        push @rows, undef;

        push @rows, @unattached;
    }

    \@rows;
};

no Any::Moose;

__PACKAGE__->meta->make_immutable;
