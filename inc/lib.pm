package inc::lib;

# $Id:$
use strict;
use warnings;
use Moose;
use Cwd;
my $lib;
BEGIN { $lib = cwd . "/lib/"; }
use Carp;
use lib "$lib";
Carp::carp("[inc::lib] $lib added to \@INC");

sub log_debug   { 1; }
sub plugin_name { 'inc::lib' }
sub dump_config { }
sub register_component { }

1;

