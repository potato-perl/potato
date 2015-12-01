package Potato::Interface::DispatchType;
use Moose::Role;

has dispatcher => (
    is       => 'ro',
    weak_ref => 1,
);

sub priority { 0 }

requires 'register';
requires 'name';

1;
