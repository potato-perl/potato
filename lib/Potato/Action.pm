use utf8;
package Potato::Action;
use Moose;
use Types::Standard qw/ArrayRef HashRef/;

my $attrs_type = HashRef->plus_coercions(
    ArrayRef,
    sub {
        my $raw_attrs = $_;
        my $attrs = {};

        foreach my $attr (@{$raw_attrs} ) {
            if ( my ( $key, $value ) = ( $attr =~ /^(.*?)(?:\(\s*(.*?)\s*\))?$/ ) ){
                push @{$attrs->{$key}}, $value;
            }
        }

        return $attrs;
    }
);

has name => (
    is  => 'ro',
    isa => 'Str',
);

has attrs => (
    is     => 'ro',
    isa    => $attrs_type,
    coerce => 1,
);

has controller => (
    is  => 'ro',
    weak_ref => 1,
);

has controller_name => (
    is  => 'ro',
    isa => 'Str',
);

has method => (
    is => 'ro',
);

has reverse_path => (
    is => 'ro',
    isa => 'Str',
    builder => 'build_reverse_path',
    lazy => 1,
);
sub build_reverse_path {
    my $self = shift;

    my $controller = $self->controller_name;
    $controller =~ s/::/\\/g;
    lc $controller . '/' . $self->name;
}

sub execute {
    my ( $self, @args ) = @_;

    $self->method->( $self->controller, @args );
}

__PACKAGE__->meta->make_immutable;
