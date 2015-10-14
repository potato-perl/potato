use utf8;
package App::DispatchTest;
use Moose;

use Potato
    dispatcher => 'PotatoX::Dispatcher::Test';

__PACKAGE__->meta->make_immutable;
