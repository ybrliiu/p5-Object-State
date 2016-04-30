package Example {

  use Object::State 'new';

  has name => 'some people';
  my_has year => 0;

  sub get_year {
    my $self = shift;
    $self->year + 10;
  }

}

use v5.14;
use warnings;
use Test::More;

subtest 'new' => sub {
  my $obj = Example->new();
  isa_ok($obj, 'Example');
  is($obj->name, 'some people', 'default name');
  my $obj2 = Example->new();
  $obj2->name('liiu');
  is($obj2->name, 'liiu');
  is($obj->name, 'some people', 'default name');
  say $obj->get_year;
  say $obj->year;
};

done_testing;
