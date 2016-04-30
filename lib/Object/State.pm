package Object::State 0.01 {
  
  use strict;
  use warnings;
  use utf8;
  use feature ':5.14';
  use Carp qw/croak/;

  sub import {
    my ($class, $option) = @_;
    $option //= '';
    {
      my $call = caller;
      say $call;
      no strict 'refs';
      push(@{"${call}::ISA"}, __PACKAGE__);
      _export($call, $_, \&{$_}) for (qw/has my_has extend DESTROY BLESS/);
      _export($call, 'new', \&BLESS) if $option eq 'new';
    }
    _import_pragma();
  }
  
  sub _export {
    my ($class, $subname, $sub) = @_;
    no strict 'refs';
    *{"${class}::${subname}"} = $sub;
  }

  sub _import_pragma {
    $_->import() for qw/strict warnings utf8/;
    feature->import(':5.14');
  }

  sub extend {
    my @list = @_;
    {
      no strict 'refs';
      my $caller = caller;
      push(@{"${caller}::ISA"}, @list);
    }
  }

  my %ATTRIBUTES = (); 
   
  my $id = 0;
  sub BLESS {
    my $class = shift;
    my $self = bless \do { my $anon }, $class;
    $$self = $id++;
    Internals::SvREADONLY($$self, 1);
    return $self;
  }
  
  sub has {
    my ($name, $default, $code) = @_;
    $ATTRIBUTES{$name} = $default // '';
    {
      my @field;
      no strict 'refs';
      *{$name} = sub {
        my $self = shift;
        $code->($self, caller) if $code;
        if (@_) {
          my $data = shift;
          $field[$$self] = $data;
          return $self;
        }
        return $field[$$self] ? $field[$$self] : $ATTRIBUTES{$name};
      };
      *{"_DESTROY_$name"} = sub {
        my $self = shift;
        delete $field[$$self];
      };
    }
  }

  sub my_has {
    my ($name, $default) = @_;
    my $sub = sub {
      no strict 'refs';
      my ($self, $call) = @_;
      my $class = ref $self;
      my %isa = map { $_ => 1 } @{"${class}::ISA"};
      croak "Can't call private attribute" if ($call ne $class && !$isa{$call});
    };
    has($name, $default, $sub);
  }

  sub DESTROY {
    my $self = shift;
    no strict 'refs';
    # ガベージコレクションちゃんとすると遅すぎる
    &{"_DESTROY_$_"}($self) for keys(%ATTRIBUTES);
  }

}

1;

1;
__END__

=encoding utf-8

=head1 NAME

Object::State - It's new $module

=head1 SYNOPSIS

    package ExampleClass;

    use Object::State;

    has 'name' => 'ryan';
    my_has 'price' => 'money';

    sub new {
      my $class = shift;
      my $self = $class->BLESS();
      return $self;
    }

    package ExampleClass;

    use Object::State 'new';
    extend 'ExampleClass';

    has 'smart' => 10;

    # print ryan smart is 10
    sub say_smart {
      my $self = shift;
      say $self->name, " smart is ", $self->smart;
    }

=head1 DESCRIPTION

Object::State is one of Inside-out Object system module.

=head1 LICENSE

Copyright (C) liiu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

liiu E<lt>yliiu_nan-na@docomo.ne.jpE<gt>

=cut

