package Test::CrossController::Controller::Root;
use Potato::Controller;
sub _namespace { '' }

sub base : Chained(/) PathPart('') CaptureArgs(0) {
    my ( $self, $arg ) = @_;

    push @{$self->app->stash->{called}}, 'root base';
}

__PACKAGE__->meta->make_immutable;
