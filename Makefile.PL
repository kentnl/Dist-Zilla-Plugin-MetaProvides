
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Generating and Populating \'provides\' in your META.yml',
  'AUTHOR' => 'Kent Fredric <kentnl@cpan.org>',
  'BUILD_REQUIRES' => {
    'Module::Build' => '0.3601'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31',
    'Module::Build' => '0.3601'
  },
  'DISTNAME' => 'Dist-Zilla-Plugin-MetaProvides',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Dist::Zilla::Plugin::MetaProvides',
  'PREREQ_PM' => {
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
  'VERSION' => '1.10027518',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM}; 
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod}; 
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



