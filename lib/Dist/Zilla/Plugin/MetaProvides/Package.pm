package Dist::Zilla::Plugin::MetaProvides::Package;

# $Id:$
use strict;
use warnings;
use Moose;
use Moose::Autobox;
use MooseX::Has::Sugar;
use MooseX::Types::Moose             (':all');
use Dist::Zilla::MetaProvides::Types (':all');

use aliased 'Module::Extract::VERSION'                 => 'Version',    ();
use aliased 'Module::Extract::Namespaces'              => 'Namespaces', ();
use aliased 'Dist::Zilla::MetaProvides::ProvideRecord' => 'Record',     ();

use namespace::autoclean;
with 'Dist::Zilla::Role::MetaProvider::Provider';

sub _packages_for {
  my ( $self, $filename, $content ) = @_;
  my $version = Version->parse_version_safely($filename);
  return map {
    Record->new(
      module  => $_,
      file    => $filename,
      version => $version,
      parent  => $self,
      )
  } Namespaces->from_file($filename);
}

sub provides {
  my $self = shift;
  return $self->zilla->files->grep( sub { $_[0]->name =~ m{\.pm$} } )->map(
    sub {
      $self->_packages_for( $_[0]->name, $_[0]->content );
    }
  )->flatten;
}

__PACKAGE__->meta->make_immutable;
1;

