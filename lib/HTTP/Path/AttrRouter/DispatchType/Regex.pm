package HTTP::Path::AttrRouter::DispatchType::Regex;
use Any::Moose;

extends 'Path::AttrRouter::DispatchType::Regex';

around list => sub {
    my ($orig, $self) = @_;
    return unless $self->used;

    my @rows = [[ 1 => 'Path'], [1 => 'Method'], [ 1 => 'Private' ]];

    for my $re (@{ $self->compiled }) {
        push @rows, [ $re->{path}, (join ',', @{$re->{action}->attributes->{Method} || ['GET', 'HEAD']}), '/' . $re->{action}->reverse ];
    }

    \@rows;
};

no Any::Moose;
__PACKAGE__->meta->make_immutable;
