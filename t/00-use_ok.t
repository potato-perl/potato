use strict;
use warnings;
use Test::More tests => 2;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

my $ok;
END { BAIL_OUT "Could not load all modules" unless $ok }

use App::DispatchTest;
ok 1, 'All modules loaded successfully';
$ok = 1;

my $app = App::DispatchTest->new;
ok $app, 'new worked';
