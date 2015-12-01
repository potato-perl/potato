package Potato::Controller;
use Moose;

use Import::Into;
use Potato::Action;
use String::CamelCase qw//;

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

has namespace => (
    is      => 'ro',
    builder => '_namespace',
);
sub _namespace {
    my $self = shift;

    my $app_name = ref $self->app;

    my $namespace = ref $self;
    $namespace =~ s/${app_name}::Controller:://;
    $namespace = String::CamelCase::decamelize( $namespace );
    $namespace =~ s|::|/|;

    return lc $namespace;
}

sub setup_actions {
    my $self = shift;

    my @actions;

    my @methods = $self->meta->get_method_with_attributes_list;
    my $package_name = ref $self;

    for ( @methods ) {
        #should we store the meta method instead? ( $_ ) [Class::MOP::Method] ???
        my $action = Potato::Action->new(
            name       => $_->name,
            attributes => $_->attributes,
            controller => $self,
            namespace  => $self->namespace,
            method     => $_,
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
