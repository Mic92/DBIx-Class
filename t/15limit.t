use strict;
use Test::More;

BEGIN {
    eval "use DBD::SQLite";
    plan $@ ? (skip_all => 'needs DBD::SQLite for testing') : (tests => 6);
}                                                                               

use lib qw(t/lib);

use_ok('DBICTest');

# test LIMIT
my $it = DBICTest::CD->search( {},
    { rows => 3,
      order_by => 'title' }
);
is( $it->count, 3, "count ok" );
is( $it->next->title, "Caterwaulin' Blues", "iterator->next ok" );
$it->next;
$it->next;
is( $it->next, undef, "next past end of resultset ok" );

# test OFFSET
my @cds = DBICTest::CD->search( {},
    { rows => 2,
      offset => 2,
      order_by => 'year' }
);
is( $cds[0]->title, "Spoonful of bees", "offset ok" );

# based on a failing criteria submitted by waswas
# requires SQL::Abstract >= 1.20
$it = DBICTest::CD->search(
    { title => [
        -and => 
            {
                -like => '%bees'
            },
            {
                -not_like => 'Forkful%'
            }
        ]
    },
    { rows => 5 }
);
is( $it->count, 1, "complex abstract count ok" );
