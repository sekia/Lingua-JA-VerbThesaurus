package Lingua::JA::VerbThesaurus::VerbCategory::Name;

use overload '""' => \&stringify;
use Moose;
use MooseX::Types::Moose qw/ArrayRef Str/;

has '_categories' => (
  is => 'ro',
  isa => ArrayRef[Str],
  handles => +{
    categories => 'elements',
    level => 'count'
  },
  init_arg => 'categories',
  required => 1,
  traits => [qw/Array/],
);

around 'BUILDARGS' => sub {
  my ($orig, $self, @args) = @_;

  if (@args == 1 and not ref $args[0]) {
      return $self->$orig(categories => [ split /-/, shift ]);
  }
  $self->$orig(@args);
};

sub stringify { join '-', shift->categories }

no Moose;

__PACKAGE__->meta->make_immutable;
