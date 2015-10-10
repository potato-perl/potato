use strict;
use warnings;
use Test::More tests => 1;

my $ok;
END { BAIL_OUT "Could not load all modules" unless $ok }

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use App::DispatchTest;

ok 1, 'All modules loaded successfully';
$ok = 1;
