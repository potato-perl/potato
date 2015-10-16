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

has subname => (
    is  => 'ro',
    isa => 'Str',
);

has attrs => (
    is  => 'ro',
    isa => $attrs_type,
    coerce => 1
);

has classname => (
    is  => 'ro',
    isa => 'Str',
);

__PACKAGE__->meta->make_immutable;
