use strict;
use warnings;
use List::MoreUtils qw/none/;
use Test::File::ShareDir -share => +{
    -dist => +{ 'Lingua-JA-VerbThesaurus' => 'share' },
};
use Test::More;
use Test::Exception;

use Lingua::JA::VerbThesaurus;

my $vthes = new_ok 'Lingua::JA::VerbThesaurus';

lives_ok {
  my $entries = $vthes->entries;
  my %visit;
  for my $entry (@$entries) {
    die 'Duplicated ID' if $visit{$entry->id};
    $visit{$entry->id} = 1;
    $entry->head_word;
    $entry->verb_category;
    $entry->has_lexeed_id and $entry->lexeed_id;
    $entry->has_cases and $entry->cases;
    $entry->has_frame and $entry->frame;
  }
} 'All entries successfully constructed';

{
  my $categ;
  lives_ok { $categ = $vthes->verb_category };
  ok $categ->is_root, '->verb_category should be root node';

  my $categ_entries = 0 + @{ $categ->entries(include_sub_categories => 1) };
  my $total_entries = 0 + @{ $vthes->entries };
  is $categ_entries, $total_entries;

  lives_ok {
    for my $entry (@{ $vthes->entries }) {
      my $sub_categ  = $categ->find($entry->verb_category);
      if (none { $_ == $entry } @{ $sub_categ->entries }) {
        die 'Entry does not found in category system: ',
          $entry->head_word, '(', $entry->id, ')';
      }
    }
  } 'Category system successfully constructed';
}

done_testing;
