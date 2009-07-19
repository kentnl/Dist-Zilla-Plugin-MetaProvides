
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'Dist-Zilla-Plugin-MetaProvides',
  NAME      => 'Dist::Zilla::Plugin::MetaProvides',
  AUTHOR    => 'Kent\ Fredric\ \<kentnl\@cpan\.org\>',
  ABSTRACT  => 'Generating\ and\ Populating\ \'provides\'\ in\ your\ META\.yml',
  VERSION   => '1.0920012',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "MooseX::Has::Sugar" => '0.0300;',
    "MooseX::Types::Moose" => '0;',
    "Module::Extract::VERSION" => '0;',
    "FindBin" => '0',
    "aliased" => '0;',
    "Class::Discover" => '1.000000',
    "Path::Class::File" => '0',
    "List::MoreUtils" => '0;',
    "Moose" => '0.65',
    "File::Find::Rule" => '0',
    "namespace::autoclean" => '0',
    "File::Find::Rule::Perl" => '0',
    "Moose::Autobox" => '0;',
    "Test::More" => '0',
    "Module::Extract::Namespaces" => '0;',
    "Dist::Zilla" => '0.091840',
    "Path::Class::Dir" => '0',
  },
);
