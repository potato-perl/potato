use utf8;
package App::DispatchTest::Controller::Root;
use Potato::Controller;

sub base : Chained(/) PathPart('') CaptureArgs(1) {
    my ( $self, $arg ) = @_;
    $self->app->stash->{called}->{base} = "Base Called";
    push(@{$self->app->stash->{args}}, $arg);
}

sub middle : Chained(base) PathPart(elddim) CaptureArgs(2) {
    my ( $self, $arg1, $arg2 ) = @_;
    push(@{$self->app->stash->{args}}, $arg1, $arg2);
    $self->app->stash->{called}->{middle} = "Middle Called";
}

sub end : Chained(middle) Args() SomeAttr(0) SomeAttr(1) SomeAttr(2) {
    my ( $self, @args ) = @_;

    $self->app->stash->{called}->{end} = "End Called";
    push(@{$self->app->stash->{args}}, @args);

    $self->app->res->stash($self->app->stash);
}

__PACKAGE__->meta->make_immutable;
