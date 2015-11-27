package Test::CrossController::Controller::First;
use Potato::Controller;

sub base : Chained(../base) PathPart(IamBATMAN.*) CaptureArgs(1) {
    my ( $self, $arg ) = @_;

    push @{$self->app->stash->{called}}, 'first base';
    push @{$self->app->stash->{args}}, $arg;
}

__PACKAGE__->meta->make_immutable;
