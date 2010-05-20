
use strict;
use warnings;

use Module::Build 0.3601;

my %module_build_args = (
  'build_requires' => {
    'Module::Build' => '0.3601'
  },
  'configure_requires' => {
    'ExtUtils::MakeMaker' => '6.31',
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Generating and Populating \'provides\' in your META.yml',
  'dist_author' => [
    'Kent Fredric <kentnl@cpan.org>'
  ],
  'dist_name' => 'Dist-Zilla-Plugin-MetaProvides',
  'dist_version' => '1.10027518',
  'license' => 'perl',
  'module_name' => 'Dist::Zilla::Plugin::MetaProvides',
  'recommends' => {},
  'requires' => {
    'Class::Discover' => '1.000001',
    'Dist::Zilla' => '2.101310',
    'File::Find::Rule' => '0.30',
    'File::Find::Rule::Perl' => '1.09',
    'FindBin' => '0',
    'List::MoreUtils' => '0.22',
    'Module::Extract::Namespaces' => '0.14',
    'Module::Extract::VERSION' => '0.13',
    'Moose' => '0.89',
    'Moose::Autobox' => '0.09',
    'MooseX::Has::Sugar' => '0.0404',
    'MooseX::Types' => '0.19',
    'MooseX::Types::Moose' => '0.19',
    'Path::Class::Dir' => '0.17',
    'Path::Class::File' => '0.17',
    'Test::More' => '0.92',
    'aliased' => '0.30',
    'namespace::autoclean' => '0.08'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
