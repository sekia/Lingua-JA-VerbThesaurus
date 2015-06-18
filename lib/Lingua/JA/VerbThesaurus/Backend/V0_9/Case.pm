package Lingua::JA::VerbThesaurus::Backend::V0_9::Case;

use Moose;
use MooseX::Types::Moose qw/ArrayRef Bool Str/;

has 'deep' => (
  is => 'ro',
  isa => Str,
  required => 1,
);

has 'example' => (
  is => 'ro',
  isa => Str,
  predicate => 'has_example',
);

# Indicates if the case is implied by verb.
has 'implied' => (
  is => 'ro',
  isa => Bool,
);

has 'surface' => (
  is => 'ro',
  isa => Str,
  predicate => 'has_surface',
);

has 'variable' => (
  is => 'ro',
  isa => ArrayRef[Str],
  default => sub { [] },
);

no Moose;

__PACKAGE__->meta->make_immutable;
