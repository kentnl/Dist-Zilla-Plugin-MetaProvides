
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

#
# This test checks all files in the dist of interest for excess whitespace,
# or bad whitespace
#

use strict;
use warnings;

use File::Find::Rule;
use File::Find::Rule::Perl;
use Path::Class qw( file  dir );
use FindBin;
use Moose::Autobox;

use Test::More qw( no_plan );
use lib "$FindBin::Bin/lib";
use TestClean;

my ($dir) = ( dir($FindBin::Bin)->parent );
my (@subdirs) = ( map { $dir->subdir($_) } qw( lib t ) );
my (@files);
push @files, File::Find::Rule->perl_file->in(@subdirs);
push @files, File::Find::Rule->name("*.ini")->in("$dir");

for (@files) {
  my $fn = file($_)->relative($dir)->stringify;
  is_clean($fn);
}