use Test::More;

use HTTP::Path::AttrRouter;

my $page;
{
    package MyController;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub page :Chained('/') :PathPart :CaptureArgs(1) {
        my ($self, $page_name) = @_;
        $page = $page_name;
    }

    sub edit :Chained('page') :PathPart { }

    package MyController::Comment;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub comment :Chained('../page') :Args(1) {
        my ($self, $id) = @_;
    }

    sub comments :Chained('../page') :PathPart('comment') {
        my ($self,) = @_;
    }

    package MyController::GetComment;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub get_comment :Chained('../page') :Args(1) Method('GET') {
        my ($self, $id) = @_;
    }

    sub get_comments :Chained('../page') :PathPart('get_comment') Method('GET') {
        my ($self,) = @_;
    }

    package MyController::HeadComment;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub head_comment :Chained('../page') :Args(1) Method('HEAD') {
        my ($self, $id) = @_;
    }

    sub head_comments :Chained('../page') :PathPart('head_comment') Method('HEAD') {
        my ($self,) = @_;
    }

    package MyController::PostComment;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub post_comment :Chained('../page') :Args(1) Method('POST') {
        my ($self, $id) = @_;
    }

    sub post_comments :Chained('../page') :PathPart('post_comment') Method('POST') {
        my ($self,) = @_;
    }

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
        my $m = $router->match('/page/hello/edit', $method);
        if ( $success ) {
            is $m->action->name, 'edit', 'edit ok';

            $m->dispatch;
            is $page, 'hello', 'page name ok';
        }
        else {
            is $m, undef, 'edit notfound';
        }
    }

    {
        my $m = $router->match('/page/hello/comment/1', $method);
        if ( $success ) {
            is $m->action->name, 'comment', 'edit ok';
            is $m->args->[0], '1', 'args ok';

            $m->dispatch;
            is $page, 'hello', 'page name ok';
        }
        else {
            is $m, undef, 'comment notfound';
        }
    }

    {
        my $m = $router->match('/page/hello/comment', $method);
        if ( $success ) {
            is $m->action->name, 'comments', 'edit ok';

            $m->dispatch;
            is $page, 'hello', 'page name ok';
        }
        else {
            is $m, undef, 'comments notfound';
        }
    }
}

for my $method ( qw/GET HEAD POST/ ) {
    my $path = lc $method;
    for my $request_method ( qw/GET HEAD POST/ ) {
        note($method . '-' . $request_method);
        {
            my $m = $router->match("/page/hello/$path\_comment/1", $request_method);
            if ( $method eq $request_method ) {
                is $m->action->name, "$path\_comment", 'edit ok';
                is $m->args->[0], '1', 'args ok';

                $m->dispatch;
                is $page, 'hello', 'page name ok';
            }
            else {
                is $m, undef, 'comment notfound';
            }
        }

        {
            my $m = $router->match("/page/hello/$path\_comment", $request_method);
            if ( $method eq $request_method ) {
                is $m->action->name, "$path\_comments", 'edit ok';

                $m->dispatch;
                is $page, 'hello', 'page name ok';
            }
            else {
                is $m, undef, 'comments notfound';
            }
        }
    }
}

done_testing;
