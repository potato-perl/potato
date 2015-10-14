use strict;
use warnings;
use Test::More tests => 4;

my $ok;
END { BAIL_OUT "Could not load all modules" unless $ok }

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use App::DispatchTest;
ok 1, 'All modules loaded successfully';
$ok = 1;

my $app = App::DispatchTest->new;
ok 2, 'new worked';

is scalar @{$app->controllers}, 1, '1 controller';
is scalar @{$app->controllers->[0]->actions}, 3, '3 actions';
