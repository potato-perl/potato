use strict;
use warnings;
use Test::More;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use App::DispatchTest;
my $app = App::DispatchTest->new;

#/root/two_args/*/*/last_unlimited_args/**

$app->dispatch( 'base/one/middle/two/three/end/four/five' );
$app->dispatch( 'base/one/middle/two/three/end/four/five/sdf/sdfsdf/sdfsdf/fdgdfg/rer/asdasd/cdsdfsf' );
$app->dispatch( 'base/one/middle/two/three/end/' );

my $dispatch_table = [
    {
        actions => [
            {
                args => 0,
                action => sub { warn Dumper( \@_ ) },
            },
            {
                args => 0,
                action => sub { warn Dumper( \@_ ) },
            },
            {
                args => 0,
                action => sub { warn Dumper( \@_ ) },
            },
        ],
        match => '/root/no_args/last_no_args',
    },
    {
        captures       => 3,
        last_unlimited => 1,
        actions        => [
            {
                args => 0,
                action => sub { warn Dumper( \@_ ) },
            },
            {
                args => 2,
                action => sub { warn Dumper( \@_ ) },
            },
            {
                args => -1,
                action => sub { warn Dumper( \@_ ) },
            },
        ],
        match => qr|^/root/two_args/(.+?)/(.+?)/last_unlimited_args/(.*)$|,
    }
];

#sub dispatch {
#    my $url = shift;
#    foreach my $dispatch ( @$dispatch_table ) {
#        my $match = $dispatch->{match};
#        my $type = ref $match;
#        my @args;
#        my $matched;
#
#        if ( !$type ) {
#        #scalar so just check it matches exactly
#            $matched = 1 if ( $url eq $match );
#        }
#        elsif ( $type eq 'Regexp' ) {
#            #if there are no args, it won't be a regexp
#            if ( @args = ( $url =~ $match ) ) {
#                if ( $dispatch->{last_unlimited} ) {
#                    #pop off the last one and split it
#                    my @last = split /\//, pop @args;
#                    push @args, @last;
#                }
#                $matched = 1;
#            }
#        }
#        #we can have a code type here, later
#
#        foreach my $action ( @{$dispatch->{actions}} ) {
#            my @action_args = splice @args, 0, $action->{args};
#            $action->{action}->( @action_args );
#        }
#    }
#};
#
#{
#    my $url = '/root/no_args/last_no_args';
#    is_deeply dispatch( $url ), $dispatch_table->[0], 'matched simple route';
#}
#
#{
#    my $url = '/root/two_args/one/two/last_unlimited_args/three/four';
#    is_deeply dispatch( $url ), $dispatch_table->[0], 'matched complex route';
#}

done_testing;
