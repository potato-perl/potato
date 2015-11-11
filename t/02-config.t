use strict;
use warnings;
use Test::More tests => 6;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

BEGIN { $ENV{HOME_PATH} = "$Bin/lib/App" };

use App::DispatchTest;
my $app = App::DispatchTest->new;

#Main app config
{
    is $app->config->{'test'}, "some test config", "Config loaded okay.";
    is $app->config->{'test_local'}, "Some local config", "Local config loaded okay.";
    is $app->config->{'test_override'}, "Some overidden config", "Local overridden loaded okay.";
}

#Model config
{
    is
        $app->model('TestModel')->config->{model_test},
        "Some model test config",
        "Model config correctly setup.";
}

#Controller config
{
    is
        $app->controller('Root')->config->{controller_test},
        "Some controller test config",
        "Controller config correctly setup.";
}

#View config
{
    is
        $app->view('TestView')->config->{view_test},
        "Some view test config",
        "View config correctly setup.";
}
