package Test::CrossController::Controller::First::Second;
use Potato::Controller;

sub base : Chained(../base) PathPart('') CaptureArgs(0) {
    my ( $self ) = @_;

    push @{$self->app->stash->{called}}, 'second base';
}

sub end : Chained(base) PathPart(end) Args() {
    my ( $self, @args ) = @_;

    push @{$self->app->stash->{called}}, 'second end';
    push @{$self->app->stash->{args}}, \@args;

    $self->app->res->stash($self->app->stash);
}

__PACKAGE__->meta->make_immutable;
