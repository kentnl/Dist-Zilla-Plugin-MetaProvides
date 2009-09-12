
use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
  module_name   => 'Dist::Zilla::Plugin::MetaProvides',
  license       => 'perl',
  dist_abstract => "Generating\ and\ Populating\ \'provides\'\ in\ your\ META\.yml",
  dist_name     => "Dist\-Zilla\-Plugin\-MetaProvides",
  dist_author   => [
"Kent\ Fredric\ \<kentnl\@cpan\.org\>",
  ],
  requires      => {
    "MooseX::Types::Moose" => '0.19',
    "MooseX::Has::Sugar" => '0.0404',
    "Module::Extract::VERSION" => '0.13',
    "FindBin" => '0',
    "aliased" => '0.30',
    "Class::Discover" => '1.000001',
    "Path::Class::File" => '0.17',
    "List::MoreUtils" => '0.22',
    "Moose" => '0.89',
    "File::Find::Rule" => '0.30',
    "namespace::autoclean" => '0.08',
    "File::Find::Rule::Perl" => '1.09',
    "Moose::Autobox" => '0.09',
    "Test::More" => '0.92',
    "Module::Extract::Namespaces" => '0.14',
    "MooseX::Types" => '0.19',
    "Dist::Zilla" => '0.092310',
    "Path::Class::Dir" => '0.17',
  },
  script_files => [ qw() ],
);

$build->create_build_script;
