use strict;
use warnings;
use Test::More tests => 3;
use Test::TempDir;
use Test::Exception;

my $test_tempdir = temp_root();

use Dist::Zilla;
my $dzil;

lives_ok {
  $dzil = Dist::Zilla->from_config( { dist_root => 't/eg/DZ2', } );
}
'Create An Instance';

lives_ok {

  $dzil->build_archive('t/eg/DZ2/DZZ');
}
'Build It';

lives_ok {

  $dzil->test;

}
'Passes Tests';
