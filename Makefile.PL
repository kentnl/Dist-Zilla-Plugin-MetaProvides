
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'Dist-Zilla-Plugin-MetaProvides',
  NAME      => 'Dist::Zilla::Plugin::MetaProvides',
  AUTHOR    => 'Kent\ Fredric\ \<kentnl\@cpan\.org\>',
  ABSTRACT  => 'Utility\ Types\ for\ the\ MetaProvides\ Plugin',
  VERSION   => '1.092000',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "Test::More" => '0',
    "File::Find::Rule" => '0',
    "namespace::autoclean" => '0',
    "FindBin" => '0',
    "Path::Class::Dir" => '0',
    "Dist::Zilla" => '0.091840',
    "File::Find::Rule::Perl" => '0',
    "Path::Class::File" => '0',
    "Moose" => '0.65',
  },
);
