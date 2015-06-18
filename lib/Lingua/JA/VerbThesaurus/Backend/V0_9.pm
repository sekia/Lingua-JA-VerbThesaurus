package Lingua::JA::VerbThesaurus::Backend::V0_9;

use Fcntl qw/:seek/;
use Lingua::JA::VerbThesaurus::Backend::V0_9::Case;
use Lingua::JA::VerbThesaurus::Backend::V0_9::Entry;
use Moose;
use Text::CSV_XS;

with qw/Lingua::JA::VerbThesaurus::Backend/;

sub case_class { __PACKAGE__ . '::Case' }

sub entry_class { __PACKAGE__ . '::Entry' }

my @columns = qw/id lexeed_id head_word
                 case1_deep case1_surface case1_example case1_filled case1_var
                 case2_deep case2_surface case2_example case2_filled case2_var
                 case3_deep case3_surface case3_example case3_filled case3_var
                 case4_deep case4_surface case4_example case4_filled case4_var
                 case5_deep case5_surface case5_example case5_filled case5_var
                 example_sentence
                 category1 category2 category3 category4 category5
                 frame comment _work_memo/;

my $csv = Text::CSV_XS->new(+{ binary => 1, empty_is_undef => 1 });
$csv->column_names(@columns);

sub _build_entries {
  my ($self) = @_;

  my $src = $self->source;
  seek $src, 0, SEEK_SET;
  my $rows = $csv->getline_hr_all($src, 1);
  [ map {
    my $row = $_;
    my @cases = map {
      my %case_attrs = (
        deep => $row->{"case${_}_deep"},
        surface => $row->{"case${_}_surface"},
        example => $row->{"case${_}_example"},
        implies => $row->{"case${_}_filled"},
        variable => $row->{"case${_}_var"}
      );
      for my $key (keys %case_attrs) {
        delete $case_attrs{$key} unless defined $case_attrs{$key};
      }
      $case_attrs{implies} = $case_attrs{implies} eq '(F)'
        if exists $case_attrs{implies};
      $case_attrs{variable} = [ split /,/, $case_attrs{variable} ]
        if exists $case_attrs{variable};
      %case_attrs
        ? $self->case_class->new(%case_attrs) : ();
    } 1 .. 5;
    my $verb_category
      = join '-', grep defined, map { $row->{"category$_"} } 1 .. 5;

    $self->entry_class->new(
      id => $_->{id},
      cases => \@cases,
      verb_category => $verb_category,
      +(defined($_->{frame})     ? (frame     => $_->{frame})     : ()),
      +(defined($_->{lexeed_id}) ? (lexeed_id => $_->{lexeed_id}) : ()),
      +(defined($_->{head_word}) ? (head_word => $_->{head_word}) : ())
    );
  } @$rows ];
}

no Moose;

__PACKAGE__->meta->make_immutable;
