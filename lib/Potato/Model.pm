package Potato::Model;

use Moose;
use Import::Into;

has app => (
    is       => 'ro',
    weak_ref => 1,
);

sub import {
    my $target = caller;
    my $class = shift;

    push @$target::ISA, $class;

    Moose->import::into( $target );
   
    my @isas = $target->meta->superclasses;
    $target->meta->superclasses( @isas, $class );
}

__PACKAGE__->meta->make_immutable;