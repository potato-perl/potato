use utf8;
package Potato;
use Moose;
use Moose::Util ();
use Potato::Utensils;

use Config::ZOMG;
use Import::Into;
use Path::Tiny ();
use FindBin ();

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

has home_path => (
    is      => 'ro',
    isa     => 'Path::Tiny',
    builder => 'setup_home_path'
);

sub setup_home_path {
    my $self = shift;
    my $class_name = ref $self;
    
    #Allow override of home path
    if ( $ENV{'HOME_PATH'} ) {
        return Path::Tiny::path( $ENV{'HOME_PATH'} );
    }

    (my $file = "${class_name}.pm") =~ s{::}{/}g;

    if ( my $inc_entry = $INC{$file} ) {
        my $path = Path::Tiny::path( $inc_entry )->parent;
        while ( ! $path->is_rootdir ) {
            $path = $path->parent;
            if ( 
                $path->child('cpanfile')->exists || 
                $path->child('Makefile.PL')->exists
            ) {
                return $path;
            }
        }
        
        #This is a bit horrible, no clone on Path::Tiny?
        return Path::Tiny::path( $inc_entry )->parent;
    }

    die "Unable to find home directory";
}

has config => (
    is      => 'ro',
    isa     => 'HashRef',
    builder => 'setup_config',
    lazy    => 1,
);

sub setup_config {
    my $self = shift;

    my $name = (split /::/, ref $self)[-1];
    Config::ZOMG->new( name => $name, path => $self->home_path )->load;
}

has controllers => (
    is      => 'ro',
    isa     => 'HashRef',
    builder => 'setup_controllers',
    lazy    => 1,
);

has models => (
    is      => 'ro',
    isa     => 'HashRef',
    builder => 'setup_models',
    lazy    => 1,
);

has views => (
    is      => 'ro',
    isa     => 'HashRef',
    builder => 'setup_views',
    lazy    => 1,
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
            $components->{$1} = $class->new( 
                app     => $self,
                config  => $self->config->{"${type}::$1"} || {}
            );
        }
    }

    $components;
}

#Quick access helpers
sub model { $_[0]->models->{$_[1]}; }
sub controller { $_[0]->controllers->{$_[1]}; }
sub view { $_[0]->views->{$_[1]}; }

__PACKAGE__->meta->make_immutable;
