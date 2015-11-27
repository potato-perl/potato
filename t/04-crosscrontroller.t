use strict;
use warnings;
use Test::More tests => 3;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::CrossController;
use PotatoX::TestRequest;
use PotatoX::TestResponse;

my $app = Test::CrossController->new;
my $req = PotatoX::TestRequest->new;
my $res = PotatoX::TestResponse->new;

ok $app->dispatch( '/IamBATMAN.*/one/end/two/three', $req, $res ), "dispatch okay";

is_deeply
    $res->stash->{called},
    [
        "root base",
        "first base",
        "second base",
        "second end"
    ],
    "correct actions called in correct order";

is_deeply
    $res->stash->{args},
    [
        'one',
        [
            'two',
            'three'
        ]
    ],
    "correct args";
