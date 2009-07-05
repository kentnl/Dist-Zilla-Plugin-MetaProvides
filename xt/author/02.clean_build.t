#
# This test checks a few things are purged out.
#

use strict;
use warnings;

use File::Find::Rule;
use File::Find::Rule::Perl;
use Path::Class qw( file  dir );
use FindBin;
use Moose::Autobox;

use Test::More qw( no_plan );

my @subdirs = qw( lib t );
my $dir     = dir($FindBin::Bin)->parent;

my @files = File::Find::Rule->perl_file->in(
  @subdirs->map( sub { $dir->subdir($_) } )->flatten );

for (@files) {
  my $fn = file($_)->relative($dir)->stringify;
  open my $fh, '<', $_ or next;
  while ( my $line = <$fh> ) {
    unlike( $line, qr/\h$/m, "$fn line $. is clear for tailing space" );
    unlike( $line, qr/\t/,   "$fn line $. is devoid of tab characters" );

    # note the next line is hackish to avoid matching itself ;)
    unlike( $line, qr/[)][{]/,
      "$fn line $. has ) followed by a space before { " );
  }
  close $fh;
}

