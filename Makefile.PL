use inc::Module::Install;

name 'Lingua-JA-VerbThesaurus';
all_from 'lib/Lingua/JA/VerbThesaurus.pm';

requires 'namespace::autoclean' => '0.12';
requires 'List::MoreUtils'      => '0.32';
requires 'Moose'                => '2.00';
requires 'MooseX::Types'        => '0.27';
requires 'MooseX::Types::IO'    => '0.03';
requires 'Text::CSV_XS'         => '0.82';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More'      => '0.98';
test_requires 'Test::Exception' => '0.31';

auto_set_repository;
auto_include;
WriteAll;
