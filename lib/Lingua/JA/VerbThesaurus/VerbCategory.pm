package Lingua::JA::VerbThesaurus::VerbCategory::Name;

# namespace::autoclean cannot be used because it cleans up functions imported by overload
use overload '""' => \&stringify;
use Moose;
use MooseX::Types::Moose qw/ArrayRef Str/;

has '_categories' => (
  is => 'ro',
  isa => ArrayRef[Str],
  required => 1,
  traits => [qw/Array/],
  handles => +{
    categories => 'elements',
    level => 'count'
  },
  init_arg => 'categories'
);

around 'BUILDARGS' => sub {
  my $orig = shift;
  my $self = shift;
  return $self->$orig(categories => [ split /-/, shift ])
    if @_ == 1 and not ref $_[0];
  $self->$orig(@_);
};

sub stringify { join '-', shift->categories }

no Moose;

__PACKAGE__->meta->make_immutable;

package Lingua::JA::VerbThesaurus::VerbCategory::Node;

use namespace::autoclean;
use Carp;
use Moose;
use MooseX::Types::Moose qw/ArrayRef HashRef Str/;

use Lingua::JA::VerbThesaurus::Types qw/VerbCategoryName VerbCategory/;

has '_entries' => (
  is => 'ro',
  isa => ArrayRef,
  lazy => 1,
  default => sub { [] },
  traits => [qw/Array/],
  handles => +{ _add_entry => 'push' },
  init_arg => 'entries'
);

has 'name' => (
  is => 'ro',
  isa => VerbCategoryName,
  required => 1,
  coerce => 1
);

has 'sub_categories' => (
  is => 'ro',
  isa => HashRef[VerbCategory],
  lazy => 1,
  default => sub { +{} },
  traits => [qw/Hash/],
  handles => +{
    sub_category_names => 'keys',
  }
);

has 'super_category' => (
  is => 'ro',
  isa => VerbCategory,
  required => 1,
  weak_ref => 1
);

sub _find {
  my ($self, $find_or_create, @path) = @_;
  return $self if @path == 0;

  my $sub_category_name = shift @path;
  my $sub_category = $self->sub_categories->{$sub_category_name};
  unless ($sub_category) {
    return unless $find_or_create;

    $sub_category
      = $self->sub_categories->{$sub_category_name}
      = __PACKAGE__->new(
        name => Lingua::JA::VerbThesaurus::VerbCategory::Name->new(
          categories => [$self->name->categories, $sub_category_name]
        ),
        super_category => $self
      );
  }
  $sub_category->_find($find_or_create, @path);
}

sub add_entry {
  my ($self, $entry) = @_;
  $self->_find(1, $entry->verb_category->categories)->_add_entry($entry);
}

sub entries {
  my ($self, %opts) = @_;
  [
    @{ $self->_entries },
    $opts{include_sub_categories}
      ? +(map { @{ $_->entries(%opts) } } values %{ $self->sub_categories })
      : +()
  ]
}

sub find {
  my ($self, $category) = @_;
  $self->_find(0, split /-/, $category) // croak "No such category: $category";
}

sub is_root { 0 }

sub is_top_level {
  my $self = shift;
  not $self->is_root and $self->super_category->is_root;
}

__PACKAGE__->meta->make_immutable;

package Lingua::JA::VerbThesaurus::VerbCategory;

use namespace::autoclean;
use Moose;

extends qw/Lingua::JA::VerbThesaurus::VerbCategory::Node/;

has '+name' => (
  default => '',
  init_arg => undef
);

has '+super_category' => (
  required => 0,
  init_arg => undef
);

sub is_root { 1 }

__PACKAGE__->meta->make_immutable;
