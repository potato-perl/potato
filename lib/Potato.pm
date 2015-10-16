use utf8;
package Potato;
use Moose;
use Moose::Util ();
use Potato::Utensils;

use Import::Into;

#the idea here is there's no class methods, unlike catalyst
#if you want to call something, you'll have to call new

our $VERSION = '0.001000';
$VERSION = eval $VERSION;

sub import {
    my $target = caller;
    my $class = shift;

    #only run this for things the use Potato
    return if $class ne __PACKAGE__;

    my %args = @_;
    die "no dispatcher" if !$args{dispatcher};

    #set $target to be us
    my @isas = $target->meta->superclasses;
    $target->meta->superclasses( @isas, $class );

    #XXX do magic to find dispatcher class,
    # Dispatcher        => Potato::Dispatcher
    # +Foo::Dispatcher  => Foo::Dispatcher
    #should this exist? i swear i've seen it somewhere, moose or html::formhandler maybe?
    # ~Dispatcher       => MyApp::Dispatcher

    #is a Dispatcher a role that we apply to us? i say yes
    # check $dispatcher does Potato::Interface::Dispatcher

# what about response, is that something that should be plugable?
# it probably is, sometimes we want to print, other times we want to write?
# or is that the view?

# but the view makes the data that we hand to the response, so i think response should
# be another pluggable thing

    my $dispatcher = $args{dispatcher};
    Moose::Util::apply_all_roles( $target, $dispatcher );

    strict->import::into( $target );
    warnings->import::into( $target );
}

sub BUILD {
    my $self = shift;

    $self->setup_finalised;
}

#hook for things to wrap
sub setup_finalised {}

has controllers => (
    is      => 'ro',
    isa     => 'HashRef',
    builder => 'setup_controllers',
);

has models => (
    is  => 'ro',
    isa => 'HashRef',
    builder => 'setup_models'
);

has views => (
    is  => 'ro',
    isa => 'HashRef',
    builder => 'setup_views'
);

sub setup_controllers {
    my ( $self ) = @_;
    $self->_setup_components("Controller");
}

sub setup_models {
    my ( $self ) = @_;
    $self->_setup_components("Model");
}

sub setup_views {
    my ( $self ) = @_;
    $self->_setup_components("View");
}

sub _setup_components {
    my ( $self, $type ) = @_;
    my $namespace = ref($self) . "::${type}";

    my $classes = Potato::Utensils::find_packages( $namespace );

    my $components = {};
    foreach my $class ( @$classes ) {
        if( $class =~ m/${namespace}::(.*)$/ ) {
            $components->{$1} = $class->new( app => $self );
        }
    }

    $components;
}

__PACKAGE__->meta->make_immutable;
