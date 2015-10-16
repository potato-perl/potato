use utf8;
package Potato::Controller;
use Moose;

use Import::Into;
use Potato::Action;

has app => (
    is       => 'ro',
    weak_ref => 1,
);

has actions => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => 'setup_actions',
);
sub setup_actions {
    my $self = shift;

    my @actions;

    my @methods = $self->meta->get_method_with_attributes_list;
    for ( @methods ) {
        #should we store the meta method instead? ( $_ )???
        my $action = Potato::Action->new(
            subname   => $_->name,
            attrs     => $_->attributes,
            classname => $_->package_name,
        );
        push @actions, $action;
    }

    \@actions;
}

sub import {
    my $target = caller;
    my $class = shift;

    push @$target::ISA, $class;

    Moose->import::into( $target );
    MooseX::MethodAttributes->import::into( $target );

    my @isas = $target->meta->superclasses;
    $target->meta->superclasses( @isas, $class );
}

__PACKAGE__->meta->make_immutable;
