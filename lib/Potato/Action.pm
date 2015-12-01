use utf8;
package Potato::Action;
use Moose;
use Types::Standard qw/ArrayRef HashRef/;

my $attrs_type = HashRef->plus_coercions(
    ArrayRef,
    sub {
        my $raw_attrs = $_;
        my $attributes = {};

        foreach my $attr (@{$raw_attrs} ) {
            if ( my ( $key, $value ) = ( $attr =~ /^(.*?)(?:\(\s*(.*?)\s*\))?$/ ) ){
                push @{$attributes->{$key}}, $value;
            }
        }

        return $attributes;
    }
);

has name => (
    is  => 'ro',
    isa => 'Str',
);

has attributes => (
    is     => 'ro',
    isa    => $attrs_type,
    coerce => 1,
);

has controller => (
    is  => 'ro',
    weak_ref => 1,
);

has namespace => (
    is  => 'ro',
    isa => 'Str',
);

has method => (
    is => 'ro',
);

has reverse_path => (
    is      => 'ro',
    isa     => 'Str',
    builder => 'build_reverse_path',
    lazy    => 1,
);
sub build_reverse_path {
    my $self = shift;

    my $reverse_path = $self->namespace . "/" . $self->name;
    if ( $reverse_path !~ /^\// ) {
        $reverse_path = "/$reverse_path";
    }

    return $reverse_path;
}
has path_part => (
    is      => 'ro',
    isa     => 'Str',
    builder => '_path_part',
    lazy    => 1,
);
sub _path_part {
    my $self = shift;

    if ( exists $self->attributes->{PathPart} ) {
        my $path_part = $self->attributes->{PathPart}->[0];
        $path_part =~ s#^(?:/|'|")##g;
        $path_part =~ s#(?:/|'|")$##g;

        return $path_part;
    }

    my $path_part = lc $self->name;
    return $path_part;
}

sub execute {
    my ( $self, @args ) = @_;

    $self->method->( $self->controller, @args );
}

__PACKAGE__->meta->make_immutable;
