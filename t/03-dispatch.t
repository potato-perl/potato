use strict;
use warnings;
use Test::More;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use App::DispatchTest;
use PotatoX::TestRequest;
use PotatoX::TestResponse;

my $app = App::DispatchTest->new;

#/root/two_args/*/*/last_unlimited_args/**
{
    my $req = new PotatoX::TestRequest;
    my $res = new PotatoX::TestResponse;
    ok $app->dispatch( 'base/one/middle/two/three/end/four/five', $req, $res ), "Called dispatch okay";
}

{
    my $req = new PotatoX::TestRequest;
    my $res = new PotatoX::TestResponse;
    my $dispatch_res = $app->dispatch( 'base/one/middle/two/three/end/four/five/six/seven/eight/nine/ten/eleven/twelve', $req, $res );
    is $dispatch_res->stash->{called}->{middle}, "Middle Called", "Middle action called, and populated stash";
    is $dispatch_res->stash->{called}->{end}, "End Called", "End action called, and populated stash";
    is_deeply $dispatch_res->stash->{args}, [
        'one', 'two', 'three',
        'four', 'five', 'six', 
        'seven', 'eight', 'nine',
        'ten', 'eleven', 'twelve'], 
    "Correct Args";
}

#End
{
    my $req = new PotatoX::TestRequest;
    my $res = new PotatoX::TestResponse;

    my $dispatch_res = $app->dispatch( 'base/one/middle/two/three/end/', $req, $res );
    is $dispatch_res->stash->{called}->{end}, "End Called", "End action called, and populated stash";
    is_deeply $dispatch_res->stash->{args}, ['one', 'two', 'three' ], "No Args";
}


done_testing;
