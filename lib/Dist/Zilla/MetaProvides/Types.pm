package Dist::Zilla::MetaProvides::Types;

# $Id:$
use strict;
use warnings;
use Moose ();
use MooseX::Types::Moose (':all');
use MooseX::Types -declare => [ 'ModVersion', 'ProviderObject', ];

subtype ModVersion, as Str | Undef;

subtype ProviderObject, as Object, where {
  $_->does('Dist::Zilla::Role::MetaProvider');
};

1;

