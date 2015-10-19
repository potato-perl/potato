use strict;
use warnings;
use Test::More tests => 8;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use App::DispatchTest;
my $app = App::DispatchTest->new;

is scalar (keys %{$app->controllers}), 1, '1 controller';
is scalar @{$app->controllers->{'Root'}->actions}, 3, '3 actions';

#Attributes
{
    my $attrs = $app->controllers->{'Root'}->actions->[2]->attrs;
    is scalar(keys %{$attrs}), 3, "Action has 3 attributes";
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
