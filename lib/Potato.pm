package Potato;
use Moose;
use Moose::Util ();

our $VERSION = '0.001000';
$VERSION = eval $VERSION;

#is this the way to do this? probably not as it goes mental
#needs more thought
sub import {
    my $target = caller;
    my $class = shift;
    my %args = @_;

    die "no dispatcher" if !$args{dispatcher};

    #first set $target to be us, minus the import method
    push @$target::ISA, $class;
    $target->meta->remove_method('import');

    my $dispatcher = $args{dispatcher};

    #XXX do magic to find dispatcher class,
    # Dispatcher        => Potato::Dispatcher
    # +Foo::Dispatcher  => Foo::Dispatcher
    #should this exist? i swear i've seen it somewhere, moose or html::formhandler maybe?
    # ~Dispatcher       => MyApp::Dispatcher

    #is a Dispatcher a role that we apply to us? i say yes
    # check $dispatcher does Potato::Interface::Dispatcher

    Moose::Util::apply_all_roles( $target, $dispatcher );
}

#the idea here is there's no class methods, unlike catalyst
#if you want to call something, you'll have to call new
sub BUILD {
    my $self = shift;

    my ( @controllers, @models, @views );
    #XXX find all the controllers|models|views
    #loop each $thing
    # check each $thing matches a potato::interface::$thing
    # $thing->new( app => $self ) #all things can have app

    # what about response, is that something that should be plugable?
    # it probably is, sometimes we want to print, other times we want to write?
    # or is that the view?

    # but the view makes the data that we hand to the response, so i think response should
    # be another pluggable thing

    $self->register_actions;
}

sub register_actions {
    #build all the actions from the controller methods
}
sub model {}
sub controller {}
sub view {}

__PACKAGE__->meta->make_immutable;
