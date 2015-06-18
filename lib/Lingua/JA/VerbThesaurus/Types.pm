package Lingua::JA::VerbThesaurus::Types;

use MooseX::Types -declare => [qw/Backend VerbCategory VerbCategoryName/];
use MooseX::Types::Moose qw/Str/;

role_type Backend,
  +{ role => 'Lingua::JA::VerbThesaurus::Backend' };

class_type VerbCategory,
  +{ class => 'Lingua::JA::VerbThesaurus::VerbCategory::Node' };

class_type VerbCategoryName,
  +{ class => 'Lingua::JA::VerbThesaurus::VerbCategory::Name' };

coerce VerbCategoryName,
  from Str,
  via {
    require Lingua::JA::VerbThesaurus::VerbCategory;
    Lingua::JA::VerbThesaurus::VerbCategory::Name->new($_);
  };

1;
