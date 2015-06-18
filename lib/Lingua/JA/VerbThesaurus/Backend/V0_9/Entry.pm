package Lingua::JA::VerbThesaurus::Backend::V0_9::Entry;

use namespace::autoclean;
use Lingua::JA::VerbThesaurus::Types qw/VerbCategoryName/;
use Moose;
use MooseX::Types::Moose qw/ArrayRef Int Str/;

has 'cases' => (
  is => 'ro',
  isa => ArrayRef['Lingua::JA::VerbThesaurus::Backend::V0_9::Case'],
  default => sub { [] },
  handles => +{ has_cases => 'count' },
  traits => [qw/Array/],
);

has 'frame' => (
  is => 'ro',
  isa => Str,
  predicate => 'has_frame',
);

has 'head_word' => (
  is => 'ro',
  isa => Str,
  required => 1,
);

has 'id' => (
  is => 'ro',
  isa => Int,
  required => 1,
);

has 'lexeed_id' => (
  is => 'ro',
  isa => Str,
  predicate => 'has_lexeed_id',
);

has 'verb_category' => (
  is => 'ro',
  isa => VerbCategoryName,
  coerce => 1,
  required => 1,
);

__PACKAGE__->meta->make_immutable;
