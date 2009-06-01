package Dist::Zilla::MetaProvides::Types;

# $Id:$
use strict;
use warnings;
use Moose ();
use MooseX::Types::Moose (':all');
use MooseX::Types -declare => ['ModVersion'];

subtype ModVersion, as Str | Undef;

1;

