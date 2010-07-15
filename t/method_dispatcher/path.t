use Test::More;

use HTTP::Path::AttrRouter;

{
    package MyController;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub index :Path { }

    sub path1 :Path('path1') { }
    sub path2 :Local { }
    sub path3 :Global {}

    package MyController::Get;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub index :Path Method('GET') { }

    sub path1 :Path('path1') Method('GET') {}
    sub path2 :Local Method('GET') { }
    sub path4 :Global Method('GET') {}
    sub path5 :Path('/path5') Method('GET') {}

    package MyController::Head;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub index :Path Method('HEAD') { }

    sub path1 :Path('path1') Method('HEAD') {}
    sub path2 :Local Method('HEAD') { }
    sub path6 :Global Method('HEAD') {}
    sub path7 :Path('/path7') Method('HEAD') {}

    package MyController::Post;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub index :Path Method('POST') { }

    sub path1 :Path('path1') Method('POST') {}
    sub path2 :Local Method('POST') { }
    sub path8 :Global Method('POST') {}
    sub path9 :Path('/path9') Method('POST') {}
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
        my $m = $router->match('/', $method);
        if ( $success ) {
            is $m->action->name, 'index', 'index ok';
            is $m->action->namespace, '', 'index ns ok';
        }
        else {
            is $m, undef, 'index notfound';
        }
    }

    {
        my $m = $router->match('/path1', $method);
        if ( $success ) {
            is $m->action->name, 'path1', 'path1 ok';
            is $m->action->namespace, '', 'path1 ns ok';
        }
        else {
            is $m, undef, 'path1 notfound';
        }
    }

    {
        my $m = $router->match('/path2', $method);
        if ( $success ) {
            is $m->action->name, 'path2', 'path2 ok';
            is $m->action->namespace, '', 'path2 ns ok';
        }
        else {
            is $m, undef, 'path2 notfound';
        }
    }

    {
        my $m = $router->match('/path3', $method);
        if ( $success ) {
            is $m->action->name, 'path3', 'path3 ok';
            is $m->action->namespace, '', 'path3 ns ok';
        }
        else {
            is $m, undef, 'path3 notfound';
        }
    }
}

my %get = (
    GET  => 1,
    HEAD => 0,
    POST => 0,
);

while  (my ($method, $success) = each %get) {
    note('get-' . $method);
    {
        my $m = $router->match('/get', $method);
        if ( $success ) {
            is $m->action->name, 'index', 'get index ok';
            is $m->action->namespace, 'get', 'get index ns ok';
        }
        else {
            is $m, undef, 'get notfound';
        }
    }

    {
        my $m = $router->match('/get/path1', $method);
        if ( $success ) {
            is $m->action->name, 'path1', 'get path1 ok';
            is $m->action->namespace, 'get', 'get index ns ok';
        }
        else {
            is $m, undef, 'get path1 notfound';
        }
    }

    {
        my $m = $router->match('/get/path2', $method);
        if ( $success ) {
            is $m->action->name, 'path2', 'get path2 ok';
            is $m->action->namespace, 'get', 'get index ns ok';
        }
        else {
            is $m, undef, 'get path2 notfound';
        }
    }

    {
        my $m = $router->match('/path4', $method);
        if ( $success ) {
            is $m->action->name, 'path4', 'get path4 ok';
            is $m->action->namespace, 'get', 'get index ns ok';
        }
        else {
            is $m, undef, 'get path4 notfound';
        }
    }

    {
        my $m = $router->match('/path5', $method);
        if ( $success ) {
            is $m->action->name, 'path5', 'get path5 ok';
            is $m->action->namespace, 'get', 'get index ns ok';
        }
        else {
            is $m, undef, 'get path5 notfound';
        }
    }
}

my %head = (
    GET  => 0,
    HEAD => 1,
    POST => 0,
);

while  (my ($method, $success) = each %head) {
    note('head-' . $method);
    {
        my $m = $router->match('/head', $method);
        if ( $success ) {
            is $m->action->name, 'index', 'head index ok';
            is $m->action->namespace, 'head', 'head index ns ok';
        }
        else {
            is $m, undef, 'head notfound';
        }
    }

    {
        my $m = $router->match('/head/path1', $method);
        if ( $success ) {
            is $m->action->name, 'path1', 'head path1 ok';
            is $m->action->namespace, 'head', 'head index ns ok';
        }
        else {
            is $m, undef, 'head path1 notfound';
        }
    }

    {
        my $m = $router->match('/head/path2', $method);
        if ( $success ) {
            is $m->action->name, 'path2', 'head path2 ok';
            is $m->action->namespace, 'head', 'head index ns ok';
        }
        else {
            is $m, undef, 'head path2 notfound';
        }
    }

    {
        my $m = $router->match('/path6', $method);
        if ( $success ) {
            is $m->action->name, 'path6', 'head path6 ok';
            is $m->action->namespace, 'head', 'head index ns ok';
        }
        else {
            is $m, undef, 'head path6 notfound';
        }
    }

    {
        my $m = $router->match('/path7', $method);
        if ( $success ) {
            is $m->action->name, 'path7', 'head path7 ok';
            is $m->action->namespace, 'head', 'head index ns ok';
        }
        else {
            is $m, undef, 'head path7 notfound';
        }
    }
}

my %post = (
    GET  => 0,
    HEAD => 0,
    POST => 1,
);

while  (my ($method, $success) = each %post) {
    note('post-' . $method);
    {
        my $m = $router->match('/post', $method);
        if ( $success ) {
            is $m->action->name, 'index', 'post index ok';
            is $m->action->namespace, 'post', 'post index ns ok';
        }
        else {
            is $m, undef, 'post notfound';
        }
    }

    {
        my $m = $router->match('/post/path1', $method);
        if ( $success ) {
            is $m->action->name, 'path1', 'post path1 ok';
            is $m->action->namespace, 'post', 'post index ns ok';
        }
        else {
            is $m, undef, 'post path1 notfound';
        }
    }

    {
        my $m = $router->match('/post/path2', $method);
        if ( $success ) {
            is $m->action->name, 'path2', 'post path2 ok';
            is $m->action->namespace, 'post', 'post index ns ok';
        }
        else {
            is $m, undef, 'post path2 notfound';
        }
    }

    {
        my $m = $router->match('/path8', $method);
        if ( $success ) {
            is $m->action->name, 'path8', 'post path8 ok';
            is $m->action->namespace, 'post', 'post index ns ok';
        }
        else {
            is $m, undef, 'post path8 notfound';
        }
    }

    {
        my $m = $router->match('/path9', $method);
        if ( $success ) {
            is $m->action->name, 'path9', 'post path9 ok';
            is $m->action->namespace, 'post', 'post index ns ok';
        }
        else {
            is $m, undef, 'post path9 notfound';
        }
    }
}

done_testing;
