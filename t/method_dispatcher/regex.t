use Test::More;

use HTTP::Path::AttrRouter;

{
    package MyController;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub root :Regex('^root$') {}

    package MyController::Get;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub local :LocalRegex('^localregex$') Method('GET') { }
    sub global :Regex('^get$') Method('GET') { }

    package MyController::Head;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub local :LocalRegex('^localregex$') Method('HEAD') { }
    sub global :Regex('^head$') Method('HEAD') { }

    package MyController::Post;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub local :LocalRegex('^localregex$') Method('POST') { }
    sub global :Regex('^post$') Method('POST') { }
}

my $router = HTTP::Path::AttrRouter->new( search_path => 'MyController' );

my %root = (
    GET  => 1,
    HEAD => 1,
    POST => 0,
);

while  (my ($method, $success) = each %root) {
    note('root-' . $method);
    {
        my $m = $router->match('/root', $method);
        if ( $success ) {
            is $m->action->name, 'root', 'root action ok';
        }
        else {
            is $m, undef, 'root notfound';
        }
    }
}

for my $method ( qw/GET HEAD POST/ ) {
    my $path = lc $method;
    for my $request_method ( qw/GET HEAD POST/ ) {
        note($method . '-' . $request_method);
        {
            my $m = $router->match("/$path/localregex", $request_method);
            if ( $method eq $request_method ) {
                is $m->action->name, 'local', 'local regex action ok';
            }
            else {
                is $m, undef, 'local regex notfound';
            }
        }

        {
            my $m = $router->match("/$path", $request_method);
            if ( $method eq $request_method ) {
                is $m->action->name, 'global', 'global regex action ok';
            }
            else {
                is $m, undef, 'global regex notfound';
            }
        }
    }
}
done_testing;
