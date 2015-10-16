package Potato::View;

use Moose;

has app => (
    is       => 'ro',
    weak_ref => 1,
);

has config => (
    is             => 'ro',
    weak_ref    => 1,
    isa         => 'HashRef'
);

sub import {
    my $target = caller;
    my $class = shift;

    push @$target::ISA, $class;

    Moose->import::into( $target );
   
    my @isas = $target->meta->superclasses;
    $target->meta->superclasses( @isas, $class );
}

sub process {
    die "You need to specify a view to use.";
}

__PACKAGE__->meta->make_immutable;