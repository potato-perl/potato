use utf8;
package Potato::Controller;
use Moose;

use Import::Into;
use Potato::Action;

has app => (
    is       => 'ro',
    weak_ref => 1,
);

has config => (
    is          => 'ro',
    weak_ref    => 1,
    isa         => 'HashRef'
);

has actions => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => 'setup_actions',
    lazy    => 1,
);

sub setup_actions {
    my $self = shift;

    my @actions;

    my @methods = $self->meta->get_method_with_attributes_list;
    my $package_name = ref $self;
    my $app_name = ref $self->app;
    $package_name =~ s/${app_name}::Controller:://;

    for ( @methods ) {
        #should we store the meta method instead? ( $_ )???
        my $action = Potato::Action->new(
            name        => $_->name,
            attrs       => $_->attributes,
            controller  => $package_name,
            method      => $_,
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
