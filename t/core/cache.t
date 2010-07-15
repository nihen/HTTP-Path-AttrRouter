use Test::More;

use File::Temp;
use HTTP::Path::AttrRouter;

{
    package MyController;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub index :Path { }
    sub index2 :Path :Args(2) { }
    sub index1 :Path :Args(1) { }
    sub index3 :Path :Args(3) { }

    package MyController::Args;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub index :Path :Args(1) {
        my ($self, $arg) = @_;
    }

    package MyController::Regex;
    use base 'HTTP::Path::AttrRouter::Controller';

    sub index :Regex('^regex/(\d+)/(.+)') {
        my ($self, @captures) = @_;
    }
}

sub runtest {
    my ($router) = @_;

    {
        my $m = $router->match('/');
        ok $m, 'match ok';
        is $m->action->name, 'index', 'action ok';
    }
    
    {
        my $m = $router->match('/one');
        ok $m, 'match ok';
        is $m->action->name, 'index1', 'action ok';
    }
    
    {
        my $m = $router->match('/one/two');
        ok $m, 'match ok';
        is $m->action->name, 'index2', 'action ok';
    }
    
    {
        my $m = $router->match('/one/two/three');
        ok $m, 'match ok';
        is $m->action->name, 'index3', 'action ok';
    }
    
    {
        my $m = $router->match('/not/found/path/action');
        ok !$m, 'not found ok';
    }
    
    {
        my $m = $router->match('/args/hoge');
        ok $m, 'match ok';
        is $m->action->name, 'index', 'action ok';
        is $m->action->namespace, 'args', 'action namespace ok';
        is $m->args->[0], 'hoge', 'args ok';
    }
    
    {
        my $m = $router->match('/args/%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF');
        ok $m, 'match ok';
        is $m->action->name, 'index', 'action ok';
        is $m->action->namespace, 'args', 'action namespace ok';
        is $m->args->[0], 'こんにちは', 'multibyte args ok';
    }
    
    {
        my $m = $router->match('/regex/1234/foo');
        ok $m, 'match ok';
        is $m->action->name, 'index', 'action ok';
        is $m->action->namespace, 'regex', 'action namespace ok';
        is $m->captures->[0], '1234', 'captures 1 ok';
        is $m->captures->[1], 'foo', 'captures 2 ok';
    }
    
    {
        my $m = $router->match('/regex/1234/%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF');
        ok $m, 'match ok';
        is $m->action->name, 'index', 'action ok';
        is $m->action->namespace, 'regex', 'action namespace ok';
        is $m->captures->[0], '1234', 'captures 1 ok';
        is $m->captures->[1], 'こんにちは', 'multibytes captures 2 ok';
    }
}

my $tmp = File::Temp->new;
$tmp->close;

my $router = HTTP::Path::AttrRouter->new(
    search_path  => 'MyController',
    action_cache => $tmp->filename,
);

runtest($router);

$router = HTTP::Path::AttrRouter->new(
    search_path  => 'MyController',
    action_cache => $tmp->filename,
);

runtest($router);

done_testing;
