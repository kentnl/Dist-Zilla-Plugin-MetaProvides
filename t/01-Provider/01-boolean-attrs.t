
use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal;
use Test::DZil qw( simple_ini );

use lib 't/lib';

use Dist::Zilla::Util::Test::KENTNL 1.001 qw( dztest );

my $dzil;

sub make_plugin {
  my @args = @_;
  $dzil = dztest();
  $dzil->add_file( 'dist.ini', simple_ini( [ 'FakePlugin' => {@args} ] ) );
  return $dzil->builder->plugin_named('FakePlugin');
}

subtest 'inherit_version boolean tests' => sub {
  ok( make_plugin( inherit_version => 1 )->inherit_version, 'inherit_verion = 1 propagates' );
  ###---
  ok( !make_plugin( inherit_version => 0 )->inherit_version, 'inherit_verion = 0 propagates' );
  ###---
  isnt(
    exception {
      isnt( make_plugin( inherit_version => 2 )->inherit_version, 2, '2 is not boolean!' );
    },
    undef,
    'Non-Zero inhert_version can not live'
  );
};

###---
subtest 'inherit_missing boolean tests' => sub {
  ok( make_plugin( inherit_missing => 1 )->inherit_missing, 'inherit_missing = 1 propagates' );
  ###---
  ok( !make_plugin( inherit_missing => 0 )->inherit_missing, 'inherit_missing = 0 propagates' );
  ###---
  isnt(
    exception {
      isnt( make_plugin( inherit_missing => 2 )->inherit_missing, 2, '2 is not boolean!' );
    },
    undef,
    'Non-Zero inhert_missing can not live'
  );
};
###---
subtest 'meta_noindex boolean tests' => sub {
  ok( make_plugin( meta_noindex => 1 )->meta_noindex, 'meta_noindex = 1 propagates' );
  ###---
  ok( !make_plugin( meta_noindex => 0 )->meta_noindex, 'meta_noindex = 0 propagates' );
  ###---
  isnt(
    exception {
      isnt( make_plugin( meta_noindex => 2 )->meta_noindex, 2, '2 is not boolean!' );
    },
    undef,
    'Non-Zero meta_noindex can not live'
  );
};
###---

done_testing;
