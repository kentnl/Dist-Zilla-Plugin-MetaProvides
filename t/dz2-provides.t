use strict;
use warnings;
use Test::More tests => 3;
#use Test::TempDir;
use Test::Exception;

#my $test_tempdir = temp_root();

use Dist::Zilla;
my $dzil;

chdir 't/eg/DZ2/';

lives_ok {
  $dzil = Dist::Zilla->from_config( {} );
}
'Create An Instance';

lives_ok {

  $dzil->build_in();
}
'Build It';


