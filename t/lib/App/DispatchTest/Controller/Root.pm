use utf8;
package App::DispatchTest::Controller::Root;
use Potato::Controller;

sub base : Chained(/) PathPart('') CaptureArgs(1) {
    my ( $self, $arg ) = @_;
warn 'base, ', $arg;
}

sub middle : Chained(base) PathPart(elddim) CaptureArgs(2) {
    my ( $self, $arg1, $arg2 ) = @_;
warn 'middle, ', $arg1, ", ", $arg2;
}

sub end : Chained(middle) Args() SomeAttr(0) SomeAttr(1) SomeAttr(2) {
    my ( $self, @args ) = @_;
warn 'end, ', join ", ", @args;
}

__PACKAGE__->meta->make_immutable;
