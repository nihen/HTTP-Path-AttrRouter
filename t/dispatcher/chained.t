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

}

my $router = HTTP::Path::AttrRouter->new( search_path => 'MyController' );

{
    my $m = $router->match('/page/hello/edit');
    is $m->action->name, 'edit', 'edit ok';

    $m->dispatch;
    is $page, 'hello', 'page name ok';
}

{
    my $m = $router->match('/page/hello/comment/1');
    is $m->action->name, 'comment', 'edit ok';
    is $m->args->[0], '1', 'args ok';

    $m->dispatch;
    is $page, 'hello', 'page name ok';
}

{
    my $m = $router->match('/page/hello/comment');
    is $m->action->name, 'comments', 'edit ok';

    $m->dispatch;
    is $page, 'hello', 'page name ok';
}

done_testing;
