
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'Data::Dumper' => '0',
    'Dist::Zilla::App::Tester' => '0',
    'File::Find' => '0',
    'File::Find::Rule' => '0.30',
    'File::Find::Rule::Perl' => '1.09',
    'File::Temp' => '0',
    'FindBin' => '0',
    'Module::Build' => '0.3601',
    'MooseX::Declare' => '0',
    'Path::Class::Dir' => '0.17',
    'Path::Class::File' => '0.17',
    'Test::Builder::Module' => '0',
    'Test::More' => '0.92',
    'Test::Perl::Critic' => '0'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Generating and Populating \'provides\' in your META.yml',
  'dist_author' => [
    'Kent Fredric <kentnl@cpan.org>'
  ],
  'dist_name' => 'Dist-Zilla-Plugin-MetaProvides',
  'dist_version' => '1.10034117',
  'license' => 'perl',
  'module_name' => 'Dist::Zilla::Plugin::MetaProvides',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Carp' => '0',
    'Class::Discover' => '1.000001',
    'Config::INI::Reader' => '0',
    'Dist::Zilla' => '2.101310',
    'Dist::Zilla::Role::MetaProvider' => '0',
    'List::MoreUtils' => '0.22',
    'Module::Extract::Namespaces' => '0.14',
    'Module::Extract::VERSION' => '0.13',
    'Moose' => '0.89',
    'Moose::Autobox' => '0.09',
    'Moose::Role' => '0',
    'MooseX::Has::Sugar' => '0.0404',
    'MooseX::Types' => '0.19',
    'MooseX::Types::Moose' => '0.19',
    'aliased' => '0.30',
    'namespace::autoclean' => '0.08'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
