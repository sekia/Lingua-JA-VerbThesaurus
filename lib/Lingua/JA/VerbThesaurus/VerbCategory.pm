package Lingua::JA::VerbThesaurus::VerbCategory;

use namespace::autoclean;
use Lingua::JA::VerbThesaurus::VerbCategory::Name;
use Lingua::JA::VerbThesaurus::VerbCategory::Node;
use Moose;

extends qw/Lingua::JA::VerbThesaurus::VerbCategory::Node/;

has '+name' => (
  default => '',
  init_arg => undef,
);

has '+super_category' => (
  required => 0,
  init_arg => undef,
);

sub is_root { 1 }

__PACKAGE__->meta->make_immutable;
