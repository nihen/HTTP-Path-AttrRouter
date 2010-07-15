use inc::Module::Install;
name 'HTTP-Path-AttrRouter';
all_from 'lib/HTTP/Path/AttrRouter.pm';
readme_from 'lib/HTTP/Path/AttrRouter.pm';
readme_markdown_from 'lib/HTTP/Path/AttrRouter.pm';
readme_pod_from 'lib/HTTP/Path/AttrRouter.pm';
githubmeta;

requires 'Path::AttrRouter' => '0.01';

tests 't/*.t t/*/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
