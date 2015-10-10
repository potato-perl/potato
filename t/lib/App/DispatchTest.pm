package DispatchTest;
use Moose;

use Potato
    dispatcher => 'PotatoX::Dispatcher::Test';

__PACKAGE__->meta->make_immutable;
