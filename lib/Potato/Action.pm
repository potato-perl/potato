use utf8;
package Potato::Action;
use Moose;

has subname => (
    is  => 'ro',
    isa => 'Str',
);

has attrs => (
    is  => 'ro',
    writer => '_attrs',
);

has classname => (
    is  => 'ro',
    isa => 'Str',
);

sub BUILD {
    my ($self, $args) = @_;
	$self->_attrs( $self->_parse_attrs($args->{attrs}) );
}

sub _parse_attrs {
	my ( $self, $raw_attrs ) = @_;
	my $attrs = {};

	foreach my $attr (@{$raw_attrs} ) {
		if ( my ( $key, $value ) = ( $attr =~ /^(.*?)(?:\(\s*(.*?)\s*\))?$/ ) ){
			push @{$attrs->{$key}}, $value;
		}
	}

	return $attrs;
}

__PACKAGE__->meta->make_immutable;
