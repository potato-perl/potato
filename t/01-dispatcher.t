use strict;
use warnings;
use Test::More tests => 6;

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

#Attributes
{
	my $attrs = $app->controllers->[0]->actions->[2	]->attrs;
	is scalar(keys %{$attrs}), 2, "Action has 2 attributes";
	is scalar(@{$attrs->{SomeAttr}}), 3, "Attribute has 3 values";
}
