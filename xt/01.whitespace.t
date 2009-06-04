use strict;
use warnings;

use File::Find::Rule;
use File::Find::Rule::Perl;
use Path::Class qw( file );
use FindBin;

use Test::More;

my @files = File::Find::Rule->perl_file->in("$FindBin::Bin/../");

plan tests => scalar @files;

for (@files) {
  unlike( file($_)->slurp, qr/\h$/, "$_ is clear for whitespace" );
}

