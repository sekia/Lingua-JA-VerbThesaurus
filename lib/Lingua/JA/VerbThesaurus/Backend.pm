package Lingua::JA::VerbThesaurus::Backend;

use namespace::autoclean;
use List::MoreUtils qw/all/;
use Moose::Role;
use MooseX::Types::IO qw/IO/;
use MooseX::Types::Moose qw/ArrayRef/;

has 'source' => (
  is => 'ro',
  isa => IO,
  required => 1
);

has 'entries' => (
  is => 'ro',
  isa => ArrayRef,
  lazy => 1,
  builder => '_build_entries'
);

requires qw/case_class entry_class _build_entries/;

sub search {
  my ($self, %conds) = @_;
  my @conds;
  while (my ($prop, $cond) = each %conds) {
    push @conds, [ $prop, sub { $_[0] ~~ $cond } ];
  }
  [ grep {
    my $entry = $_;
    all {
      my ($prop, $cond) = @$_;
      $cond->($entry->$prop);
    } @conds;
  } @{ $self->entries } ];
}

1;
