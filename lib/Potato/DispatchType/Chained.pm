package Potato::DispatchType::Chained;
use Moose;

with "Potato::Interface::DispatchType";

use Scalar::Util ();
use List::Util ();

sub register {
    my ( $self, $action ) = @_;

    #ignore mid chain
    return if ( exists $action->attrs->{CaptureArgs} );

    #XXX die if too many Chained
    #XXX also work with ChainedParent

    my @path_parts;
    my $arg_count;

    #no args is the same as unlimited
    my $args = $action->attrs->{Args};
    if ( $args && defined $args->[0] && Scalar::Util::looks_like_number( $args->[0] ) ) {
        $arg_count = $args->[0];
        unshift @path_parts, ((undef) x $args->[0] );
    }
    else {
        $arg_count = -1;
        unshift @path_parts, [];
    }
    unshift @path_parts, $action->name;

    my @actions = ( {
        args    => $arg_count,
        action  => $action,
    } );

    my $chained_action = $self->parent_action_for( $action );
    while ( $chained_action ) {
        my $capture_args = $chained_action->attrs->{CaptureArgs};

        my $capture_arg_count;
        if ( $capture_args && defined $capture_args->[0] ) {
            $capture_arg_count = $capture_args->[0];
            unshift @path_parts, ((undef) x $capture_args->[0] );
        }
        unshift @path_parts, $chained_action->name;

        unshift @actions, {
            args    => $capture_arg_count,
            action  => $chained_action,
        };

        $chained_action = $self->parent_action_for( $chained_action );
    }

    my @match_parts;
    foreach ( @path_parts ) {
        if ( defined $_ ) {
            if ( ref $_ eq 'ARRAY' ) {
                push @match_parts, '(.*)';
            }
            else {
                push @match_parts, quotemeta $_;
            }
        }
        else {
            push @match_parts, '(.+?)';
        }
    }

    my $match_str = join '/', @match_parts;
    my $match_regex = qr/^${match_str}$/;

    {
        type    => 'chained',
        actions => \@actions,
        match   => $match_regex,
    }
}

sub parent_action_for {
    my ( $self, $action ) = @_;

    my $chained_to = $action->attrs->{Chained}->[0];
    $self->action_for( lc $action->controller_name . "/$chained_to");
}

sub action_for {
    my ( $self, $path ) = @_;

    List::Util::first { $_->reverse_path eq $path } @{$self->dispatcher->actions};
}

__PACKAGE__->meta->make_immutable;
