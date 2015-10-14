use utf8;
package Potato::Action;
use Moose;

has subname => (
    is  => 'ro',
    isa => 'Str',
);
has attrs => (
    is  => 'ro',
    isa => 'ArrayRef',
);
has classname => (
    is  => 'ro',
    isa => 'Str',
);

__PACKAGE__->meta->make_immutable;
