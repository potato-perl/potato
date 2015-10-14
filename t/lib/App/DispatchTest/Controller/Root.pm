use utf8;
package App::DispatchTest::Controller::Root;
use Potato::Controller;

sub base : PathPrefix CaptureArgs(1) {
    my ( $self, $arg ) = @_;
}

sub middle : PathPart(elddim) CaptureArgs(2) {
    my ( $self, $arg1, $arg2 ) = @_;
}

sub end : Args(0) {
    my ( $self ) = @_;
}

__PACKAGE__->meta->make_immutable;
