
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
    "File::Find::Rule" => '0',
    "namespace::autoclean" => '0',
    "FindBin" => '0',
    "File::Find::Rule::Perl" => '0',
    "Class::Discover" => '1.000000',
    "Test::More" => '0',
    "Dist::Zilla" => '0.091840',
    "Path::Class::Dir" => '0',
    "Path::Class::File" => '0',
    "Moose" => '0.65',
  },
  script_files => [ qw() ],
);

$build->create_build_script;
