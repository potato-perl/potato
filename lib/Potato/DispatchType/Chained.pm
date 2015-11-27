package Potato::DispatchType::Chained;
use Moose;

with "Potato::Interface::DispatchType";

use Scalar::Util qw//;

sub name { 'chained' }

sub register {
    my ( $self, $action ) = @_;

    #ignore mid chain
    return if ( exists $action->attributes->{CaptureArgs} );

    #XXX die if too many Chained
    #XXX also work with ChainedParent

    my @path_parts;
    my $arg_count;

    #no args is the same as unlimited
    my $args = $action->attributes->{Args};
    if ( $args && defined $args->[0] && Scalar::Util::looks_like_number( $args->[0] ) ) {
        $arg_count = $args->[0];
        unshift @path_parts, ((undef) x $args->[0] );
    }
    else {
        $arg_count = -1;
        unshift @path_parts, [];
    }
    unshift @path_parts, $action->path_part;
    my @actions = ( {
        args    => $arg_count,
        action  => $action,
    } );

    my $chained_action = $self->parent_action_for( $action );
    while ( $chained_action ) {
        my $capture_args = $chained_action->attributes->{CaptureArgs};

        my $capture_arg_count;
        if ( $capture_args && defined $capture_args->[0] ) {
            $capture_arg_count = $capture_args->[0];
            unshift @path_parts, ((undef) x $capture_args->[0] );
        }
        unshift @path_parts, $chained_action->path_part;

        unshift @actions, {
            args    => $capture_arg_count,
            action  => $chained_action,
        };

        $chained_action = $self->parent_action_for( $chained_action );
    }

    my @match_parts;
    my $dynamic_uri;
    foreach my $path_part ( @path_parts ) {
        if ( ref $path_part eq 'ARRAY' ) {
            #unlimited args
            push @match_parts, \'(.*?)';
            $dynamic_uri = 1;
        }
        elsif ( !defined $path_part ) {
            #1 arg
            push @match_parts, \'(.+?)';
            $dynamic_uri = 1;
        }
        else {
            push @match_parts, $path_part if $path_part ne '';
        }
    }

    #we only know if we need to escape the match_parts after we've built them
    if ( $dynamic_uri ) {
        foreach my $match_part ( @match_parts ) {
            if ( !ref $match_part ) {
                #dynamic_uri's need the user parts escaping
                $match_part = quotemeta $match_part;
            }
            else {
                #don't quote it, but dereference it
                $match_part = $$match_part;
            }
        }
    }
    my $match_str = join '/', @match_parts;
    if ( $match_str !~ /^\// ) {
        $match_str = "/$match_str";
    }
    my $match = qr/^${match_str}$/;

    {
        type    => $self->name,
        actions => \@actions,
        match   => $match,
    }
}

sub parent_action_for {
    my ( $self, $action ) = @_;

    my $chained_to = $action->attributes->{Chained}->[0];

    #root action is end
    return if $chained_to eq '/';

    if ( $chained_to =~ s/^\.\.\/// ) {
        my @action_namespace_parts = split /\//, $action->namespace;
        if ( scalar @action_namespace_parts > 1 ) {
            #get rid of the last part
            pop @action_namespace_parts;
            $chained_to = "/" . join( "/", @action_namespace_parts ) . "/$chained_to";
        }
        else {
            $chained_to = "/$chained_to";
        }
    }

    my $action_path;
    if ( $chained_to =~ /^\// ){
        $action_path = $chained_to;
    }
    else {
        $action_path = join ('/', $action->namespace, $chained_to );

        if ( $action_path !~ /^\// ){
            $action_path = "/$action_path";
        }
    }
    my $parent_action = $self->dispatcher->action_for( $action_path );

    #make sure we don't get loops of actions chained to themselves
    return if Scalar::Util::refaddr( $parent_action ) == Scalar::Util::refaddr( $action );

    $parent_action;
}

__PACKAGE__->meta->make_immutable;
