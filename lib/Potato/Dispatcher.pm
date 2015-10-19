package Potato::Dispatcher;
use Moose;

use Potato::Utensils;

has app => (
    is       => 'ro',
    weak_ref => 1,
);

#find all the dispatch types
has dispatch_types => (
    is      => 'ro',
    isa     => 'ArrayRef[Object]',
    builder => 'setup_dispatch_types',
    lazy    => 1,
);
sub setup_dispatch_types {
    my $self = shift;

    my $namespace = 'Potato::DispatchType';
    my $classes = Potato::Utensils::find_packages( 'Potato::DispatchType' );

    my @dispatch_types;
    foreach my $class ( @$classes ) {
        if( $class =~ m/${namespace}::(.*)$/ ) {
            push @dispatch_types, $class->new(
                dispatcher => $self,
            );
        }
    }

    [ sort { $a->priority <=> $b->priority  } @dispatch_types ];
}

#might be able to remove this
has actions => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => 'setup_actions',
    lazy    => 1,
);
sub setup_actions {
    my $self = shift;

    [map { @{$_->actions} } values %{$self->app->controllers}];
}

has dispatch_table => (
    is       => 'ro',
    isa      => 'ArrayRef[HashRef]',
    builder  => 'setup_dispatch_table',
);
sub setup_dispatch_table {
    my ( $self, $actions ) = @_;

    my @matches;
    #sort actions in to types, for now it's just chained
    foreach my $action ( @{$self->actions} ) {
        foreach ( @{$self->dispatch_types} ) {
            my $registered = $_->register( $action );
            if ( $registered ) {
                push @matches, $registered;
                last;
            }
        }
    }

    \@matches;
}

sub dispatch {
    my ( $self, $uri ) = @_;

    #localise the request and response
    foreach my $dispatch ( @{$self->dispatch_table} ) {
        my $match = $dispatch->{match};
        my $type = ref $match;
        my @args;
        my $matched;

        if ( !$type ) {
        #scalar so just check it matches exactly
            $matched = 1 if ( $uri eq $match );
        }
        elsif ( $type eq 'Regexp' ) {
            #if there are no args, it won't be a regexp
            if ( @args = ( $uri =~ $match ) ) {
                #the last action has unlimted args
                if ( $dispatch->{actions}->[-1]->{args} == -1 ) {
                    #pop off the last one and split it
                    my @last = split /\//, pop @args;
                    push @args, @last;
                }
                $matched = 1;
            }
        }
        #we can have a code type here, later

        next if !$matched;

        foreach my $matched ( @{$dispatch->{actions}} ) {
            my @action_args = splice @args, 0, $matched->{args};

            $matched->{action}->execute( @action_args );
        }
        return;
    }
    #go to the default action
}

__PACKAGE__->meta->make_immutable;
