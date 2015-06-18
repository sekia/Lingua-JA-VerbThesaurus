package Lingua::JA::VerbThesaurus::Backend;

use namespace::autoclean;
use List::MoreUtils qw/all any/;
use Moose::Role;
use MooseX::Types::IO qw/IO/;
use MooseX::Types::Moose qw/ArrayRef/;

has 'entries' => (
  is => 'ro',
  isa => ArrayRef,
  lazy => 1,
  builder => '_build_entries'
);

has 'source' => (
  is => 'ro',
  isa => IO,
  required => 1
);

requires qw/_build_entries case_class entry_class/;

sub search {
  my ($self, %conds) = @_;
  my @conds;
  while (my ($prop, $cond) = each %conds) {
    push @conds, [
        $prop,
        sub {
            my ($value) = @_;

            if (ref $cond eq 'ARRAY') {
                any { $value eq $_ } @$cond;
            } elsif (ref $cond eq 'CODE') {
                $cond->($value);
            } elsif (ref $cond eq 'Regexp') {
                $value =~ $cond;
            } else {
                $value eq $cond;
            }
        }
    ];
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
