package Potato::Action;
use Moose;

#this represents a controller action, and will be used by the dispatcher to call methods

__PACKAGE__->meta->make_immutable;
