package  inc::Dist::Zilla::Plugin::MetaProvides::Class;

# $Id:$
use strict;
use warnings;
use Moose;
use Cwd;
use Data::Dump qw( dump );
my $lib = "";
BEGIN {
  $lib = cwd . "/lib/";
}
use lib "$lib";
use Dist::Zilla::Plugin::MetaProvides::Class ();

print "Bootstrapping Plugin::MetaProvides::Class\n";
extends 'Dist::Zilla::Plugin::MetaProvides::Class';

__PACKAGE__->meta->make_immutable;

1;

