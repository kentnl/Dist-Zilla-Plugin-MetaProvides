
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'File::Find' => '0',
    'File::Temp' => '0',
    'Module::Build' => '0.3601',
    'Test::More' => '0.88'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Generating and Populating \'provides\' in your META.yml',
  'dist_author' => [
    'Kent Fredric <kentnl@cpan.org>'
  ],
  'dist_name' => 'Dist-Zilla-Plugin-MetaProvides',
  'dist_version' => '1.11034201',
  'license' => 'perl',
  'module_name' => 'Dist::Zilla::Plugin::MetaProvides',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Dist::Zilla::Role::MetaProvider' => '0',
    'Moose' => '0',
    'Moose::Role' => '0',
    'MooseX::Types' => '0',
    'MooseX::Types::Moose' => '0',
    'namespace::autoclean' => '0'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
