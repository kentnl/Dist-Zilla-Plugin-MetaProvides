
use strict;
use warnings;

use Test::More;

use lib 't/lib';

use TZil;
use Data::Dump qw( dump );

dump test_config({
  dist_root => 'corpus/dist/DZT',
  ini => [
    'GatherDir',
    [ 'Prereqs' => { 'Test::Simple' => '0.88' } ],
    [ 'FakePlugin' => {} ],
  ],
  post_build_callback => sub {
    my $config = shift;
    die $config->{error} if $config->{error};
  },
  find_plugin => 'FakePlugin',
})->metadata;