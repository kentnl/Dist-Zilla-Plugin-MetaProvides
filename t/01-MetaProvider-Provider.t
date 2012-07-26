
use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal;

use lib 't/lib';

use Dist::Zilla::Util::Test::KENTNL 0.01000004 qw( test_config );

sub make_plugin {
  my @args = @_;
  return test_config(
    {
      dist_root           => 'corpus/dist/DZT',
      ini                 => [ 'GatherDir', [ 'Prereqs' => { 'Test::Simple' => '0.88' } ], [ 'FakePlugin' => {@args} ], ],
      post_build_callback => sub {
        my $config = shift;
        die $config->{error} if $config->{error};
      },
      find_plugin => 'FakePlugin',
    }
  );
}

sub make_plugin_metanoindex {
  my $config = shift;
  return test_config(
    {
      dist_root => 'corpus/dist/DZT',
      ini       => [
        'GatherDir',
        [ 'Prereqs'     => { 'Test::Simple' => '0.88' } ],
        [ 'FakePlugin'  => $config->{fakeplugin} ],
        [ 'MetaNoIndex' => $config->{noindex} ],
      ],
      post_build_callback => sub {
        my $config = shift;
        die $config->{error} if $config->{error};
      },
      find_plugin => 'FakePlugin',
    }
  );
}

subtest 'boolean attribute tests' => sub {
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
};

subtest '_resolve_version tests' => sub {
  subtest 'default behaviour' => sub {
    my $plugin = make_plugin();
    is_deeply(
      [ $plugin->_resolve_version(4.0) ],
      [ 'version', '0.001' ],
      'By default, discovered versions ignored, dzils used instead'
    );
    is_deeply(
      [ $plugin->_resolve_version(undef) ],
      [ 'version', '0.001' ],
      'By default, undef versions dont matter, dzils used instead'
    );
  };
  subtest 'inherit_version => 0, inherit_missing => 0 behaviour' => sub {
    my $plugin = make_plugin( inherit_missing => 0, inherit_version => 0 );
    is_deeply(
      [ $plugin->_resolve_version('4.0') ],
      [ 'version', '4.0' ],
      'without version inheritance, defined versions pass-through'
    );
    is_deeply( [ $plugin->_resolve_version(undef) ], [], 'without version inheritance, undefined versions emit empty arrays' );
  };
  subtest 'inherit_version => 0, inherit_missing => 1 behaviour' => sub {
    my $plugin = make_plugin( inherit_missing => 1, inherit_version => 0 );
    is_deeply(
      [ $plugin->_resolve_version('4.0') ],
      [ 'version', '4.0' ],
      'with "only missing" version inheritance, defined versions pass-through'
    );
    is_deeply(
      [ $plugin->_resolve_version(undef) ],
      [ 'version', '0.001' ],
      'with "only missing" version inheritance, undefined versions default to package version'
    );
  };
  subtest 'inherit_version => 1, inherit_missing => 0 behaviour' => sub {
    my $plugin = make_plugin( inherit_version => 1, inherit_missing => 0 );
    is_deeply(
      [ $plugin->_resolve_version(4.0) ],
      [ 'version', '0.001' ],
      'with forced version inheritance, discovered versions ignored, dzils used instead'
    );
    is_deeply(
      [ $plugin->_resolve_version(undef) ],
      [ 'version', '0.001' ],
      'with forced version inheritance, undef versions dont matter, dzils used instead'
    );
  };
  subtest 'inherit_version => 1, inherit_missing => 1 behaviour' => sub {
    my $plugin = make_plugin( inherit_version => 1, inherit_missing => 0 );
    is_deeply(
      [ $plugin->_resolve_version(4.0) ],
      [ 'version', '0.001' ],
      'with forced version inheritance, inherit_missing has no impact'
    );
    is_deeply(
      [ $plugin->_resolve_version(undef) ],
      [ 'version', '0.001' ],
      'with forced version inheritance, inherit_missing has no impact'
    );
  };
};

subtest '_try_regen_metadata tests' => sub {
  if ( not defined eval 'use Dist::Zilla::Plugin::MetaNoIndex;1' ) {
    plan skip_all => 'MetaNoIndex subtests invaid without the plugin';

    #return;
  }

  subtest 'empty noindex params' => sub {

    my $plugin = make_plugin_metanoindex( { fakeplugin => {}, noindex => {} } );
    my $metadata = {};
    is( exception { $metadata = $plugin->_try_regen_metadata() }, undef, 'regenerting metadata manually does not fail' );
    is_deeply( $metadata, { no_index => {} }, 'Metadata is empty' );

  };
  subtest 'noindex params arrive' => sub {
    my $plugin = make_plugin_metanoindex( { fakeplugin => {}, noindex => { file => ['foo.pl'] } } );
    my $metadata = {};
    is( exception { $metadata = $plugin->_try_regen_metadata() }, undef, 'regenerting metadata manually does not fail' );
    is_deeply( $metadata, { no_index => { file => ['foo.pl'] } }, 'NoIndex params arrive' );
  };
};

subtest '_apply_meta_noindex tests' => sub {
  if ( not defined eval 'use Dist::Zilla::Plugin::MetaNoIndex;1' ) {
    plan skip_all => 'MetaNoIndex subtests invaid without the plugin';

    #return;
  }

  my $rules = {
    file      => ['foo.pl'],
    dir       => [ 'ignoreme', 'ignoreme/too' ],
    package   => ['Test::YouShouldNot::SeeThis'],
    namespace => ['Test::ThisIsAlso'],
  };
  my ( $normal_plugin, $noindex_plugin );
  is(
    exception {
      $normal_plugin  = make_plugin_metanoindex( { fakeplugin => { meta_noindex => 0 }, noindex => $rules } );
      $noindex_plugin = make_plugin_metanoindex( { fakeplugin => { meta_noindex => 1 }, noindex => $rules } );
    },
    undef,
    'object construction is successful'
  );
  my $example_items;
  is(
    exception {
      require Dist::Zilla::MetaProvides::ProvideRecord;
      $example_items->{A} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => 'foo.pl',
        module  => '_THISDOESNOTMATTER',
        version => 1.0,
        parent  => $normal_plugin,
      );
      $example_items->{B} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => 'bar.pl',
        module  => '_THISDOESNOTMATTER',
        version => 1.0,
        parent  => $normal_plugin,
      );
      $example_items->{C} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => 'ignoreme/quux.pl',
        module  => '_THISDOESNOTMATTER',
        version => 1.0,
        parent  => $normal_plugin,
      );
      $example_items->{D} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => 'dontignoreme/quux.pl',
        module  => '_THISDOESNOTMATTER',
        version => 1.0,
        parent  => $normal_plugin,
      );
      $example_items->{E} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => 'ignoreme/too/quux.pl',
        module  => '_THISDOESNOTMATTER',
        version => 1.0,
        parent  => $normal_plugin,
      );
      $example_items->{F} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => 'dontignoreme/too/quux.pl',
        module  => '_THISDOESNOTMATTER',
        version => 1.0,
        parent  => $normal_plugin,
      );
      $example_items->{G} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => '_THISDOESNOTMATTER',
        module  => 'Test::YouShouldNot::SeeThis',
        version => 1.0,
        parent  => $normal_plugin,
      );
      $example_items->{H} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => '_THISDOESNOTMATTER',
        module  => 'Test::YouShould::SeeThis',
        version => 1.0,
        parent  => $normal_plugin,
      );
      $example_items->{I} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => '_THISDOESNOTMATTER',
        module  => 'Test::YouShouldNot::SeeThis::ActuallyYouShould',
        version => 1.0,
        parent  => $normal_plugin,
      );
      $example_items->{J} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => '_THISDOESNOTMATTER',
        module  => 'Test::ThisIsAlso::Forbidden',
        version => 1.0,
        parent  => $normal_plugin,
      );
      $example_items->{K} = Dist::Zilla::MetaProvides::ProvideRecord->new(
        file    => '_THISDOESNOTMATTER',
        module  => 'Test::ThisIsAlso::ATest',
        version => 1.0,
        parent  => $normal_plugin,
      );
    },
    undef,
    'Test item construction does not die in a fire'
  );
  my %items = %{$example_items};
  is_deeply(
    [ $normal_plugin->_apply_meta_noindex( @items{qw( A B C D E F G H I J K )} ) ],
    [ @items{qw( A B C D E F G H I J K )} ],
    'Normal ignorance works still'
  );
  is_deeply(
    [ $noindex_plugin->_apply_meta_noindex( @items{qw( A B C D E F G H I J K )} ) ],
    [ @items{qw( B D F H I )} ],
    'NoIndex Filtering application works'
  );
};

done_testing;
