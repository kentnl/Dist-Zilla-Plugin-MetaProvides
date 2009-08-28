package  inc::Dist::Zilla::Plugin::MetaProvides::Package;

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
use Dist::Zilla::Plugin::MetaProvides::Package ();

print "Bootstrapping Plugin::MetaProvides::Package\n";
extends 'Dist::Zilla::Plugin::MetaProvides::Package';

__PACKAGE__->meta->make_immutable;

1;

