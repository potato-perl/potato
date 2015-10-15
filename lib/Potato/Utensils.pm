use utf8;
package Potato::Utensils;
use strict;
use warnings;

#this is a class of helpers

use Module::Pluggable::Object;

sub find_packages {
    my $path = shift;

    my @packages = Module::Pluggable::Object->new(
        search_path => [ $path ],
        require     => 1,
    )->plugins;

    \@packages;
}

1;
