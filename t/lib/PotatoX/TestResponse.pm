package PotatoX::TestResponse;

use Moose;

has 'stash' => (
    isa     => 'HashRef',
    is      => 'rw',
    default => sub { return {}; }
);

__PACKAGE__->meta->make_immutable;