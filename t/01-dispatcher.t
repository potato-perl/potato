use strict;
use warnings;
use Test::More tests => 10;

my $ok;
END { BAIL_OUT "Could not load all modules" unless $ok }

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use App::DispatchTest;
ok 1, 'All modules loaded successfully';
$ok = 1;

my $app = App::DispatchTest->new;
ok 2, 'new worked';

is scalar (keys %{$app->controllers}), 1, '1 controller';
is scalar @{$app->controllers->{'Root'}->actions}, 3, '3 actions';

#Attributes
{
    my $attrs = $app->controllers->{'Root'}->actions->[2]->attrs;
    is scalar(keys %{$attrs}), 2, "Action has 2 attributes";
    is scalar(@{$attrs->{SomeAttr}}), 3, "Attribute has 3 values";
}

#Models
{
	my $models = $app->models;
	is scalar(keys %{$models}), 1, "One model defined.";
	ok defined($models->{'TestModel'}), "TestModel is defined.";
}

#Views
{
	my $views = $app->views;
	is scalar(keys %{$views}), 1, "One view defined.";
	ok defined($views->{'TestView'}), "TestView is defined.";	
}