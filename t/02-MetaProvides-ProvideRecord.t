use strict;
use warnings;

use Test::More 0.96;
use lib 't/lib';

use Dist::Zilla::Util::Test::KENTNL qw( test_config );
use Dist::Zilla::MetaProvides::ProvideRecord;
use Test::Fatal;
use Scalar::Util qw( refaddr );

my $fake_dzil = test_config(
  {
    dist_root => 'corpus/dist/DZT',
    ini       => [ 'GatherDir', [ 'Prereqs' => { 'Test::Simple' => '0.88' } ], [ 'FakePlugin' => {} ] ],
  }
);

my $record;

is(
  exception {
    $record = Dist::Zilla::MetaProvides::ProvideRecord->new(
      version => '1.0',
      module  => 'FakeModule',
      file    => 'fakefile',
      parent  => $fake_dzil->plugin_named('FakePlugin'),
    );
  },
  undef,
  'Construction works'
);

can_ok( $record, 'version' );
is( $record->version, '1.0', 'version is consistent' );

can_ok( $record, 'module' );
is( $record->module, 'FakeModule', 'module is consistent' );

can_ok( $record, 'file' );
is( $record->file, 'fakefile', 'file is consistent' );

can_ok( $record, 'parent' );
is( refaddr $record->parent, refaddr $fake_dzil->plugin_named('FakePlugin'), 'parent link is right' );

can_ok( $record, 'zilla' );
is( refaddr $record->zilla, refaddr $fake_dzil , 'dzil link is right' );

can_ok( $record, '_resolve_version' );

is_deeply( [ $record->_resolve_version(3.1415) ], [ 'version', '0.001' ], '_resolve_version internal works as expected' );

can_ok( $record, 'copy_into' );

my $hash = {};
$record->copy_into($hash);

is_deeply(
  $hash,
  {
    FakeModule => {
      file    => 'fakefile',
      version => '0.001',
    }
  },
  'copy_into structures match'
);

done_testing;
