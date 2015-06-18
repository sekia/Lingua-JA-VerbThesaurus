package Lingua::JA::VerbThesaurus;

use 5.012;
use utf8;
use Carp;
# Types should not be imported into this namespace because importable symbols
# conflict with already existing classes.
use Lingua::JA::VerbThesaurus::Types;
use Lingua::JA::VerbThesaurus::VerbCategory;
use Moose;
use MooseX::Types::IO qw/IO/;
use MooseX::Types::Moose qw/Num Str/;
use UNIVERSAL::require;

our $VERSION = '0.01';

has 'backend' => (
  is => 'ro',
  isa => Lingua::JA::VerbThesaurus::Types::Backend,
  builder => '_build_backend',
  handles => [qw/search entries case_class entry_class/],
  lazy => 1,
);

has 'source' => (
  is => 'ro',
  isa => IO,
  coerce => 1,
  builder => '_build_source',
  lazy => 1,
);

has 'thesaurus_version' => (
  is => 'ro',
  isa => Str,
  default => '0.902',
);

has 'verb_category' => (
  is => 'ro',
  isa => Lingua::JA::VerbThesaurus::Types::VerbCategory,
  builder => '_build_verb_category',
  lazy => 1,
);

sub _build_backend {
  my $self = shift;

  my $backend = $self->thesaurus_version =~ /^0\.9/
      ? 'V0_9'
      : croak 'Unknown version of thesaurus';

  my $class = "Lingua::JA::VerbThesaurus::Backend::${backend}";
  $class->require or croak $@;
  $class->new(source => $self->source);
}

sub _build_source {
  File::ShareDir->use('dist_file') or croak $@;
  dist_file('Lingua-JA-VerbThesaurus', 'vthesaurus.csv');
}

sub _build_verb_category {
  my $category = Lingua::JA::VerbThesaurus::VerbCategory->new;
  for my $entry (@{ shift->entries }) { $category->add_entry($entry); }
  $category;
}

no Moose;

__PACKAGE__->meta->make_immutable;

=head1 NAME

Lingua::JA::VerbThesaurus - A perl module for access to verb thesaurus

=head1 SYNOPSIS

  use utf8;
  use Lingua::JA::VerbThesaurus;
  
  my $vthes = Lingua::JA::VerbThesaurus->new;
  # Search entries for word "run"
  my $entries = $vthes->search(head_word => '走る');
  for my $entry (@$entries) {
    $entry->id;
    $entry->head_word; # '走る'
    $entry->lexeed_id;
    $entry->verb_category;
    $entry->frame;
    $entry->cases;
  }
  
  my $category = $vthes->verb_category;
  my $sub_categ = $category->find('状態変化あり-位置変化-位置変化（物理）');
  for my $entry (@{ $sub_categ->entries(include_sub_categories => 1) }) {
    ...
  }

=head1 DESCRIPTION

Lingua::JA::VerbThesaurus is a perl module that ease you to access to Thesaurus of Predicate-Argument Structure of Japanese Verbs (動詞項構造シソーラス; refer SEE ALSO section).

=head1 AUTHOR

Koichi SATOH E<lt>sekia@cpan.orgE<gt>

=head1 SEE ALSO

Thesaurus of Predicate-Argument Structure of Japanese Verbs - L<http://cl.it.okayama-u.ac.jp/rsc/data/index.html> (Japanese)

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2011 Koichi SATOH

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=head2 Thesaurus of Predicate-Argument Structure of Japanese Verbs

This module bundles Thesaurus of Predicate-Argument Structure of Japanese Verbs.

Copyright (c) 2010 Koichi Takeuchi, Kentaro Inui, Nao Takeuchi, Atsushi Fujita

The thesaurus was developed under support of MEXT Grant-in-Aid for Scientific Research (B) "Building resources and a model for computing paraphrase based on lexical semantics" (17300047).

=cut
