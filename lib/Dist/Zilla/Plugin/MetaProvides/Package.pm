package Dist::Zilla::Plugin::MetaProvides::Package;

# $Id:$
use strict;
use warnings;
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose (':all');
use Moose::Autobox;
use Module::Extract::VERSION    ();
use Module::Extract::Namespaces ();
use namespace::autoclean;
with 'Dist::Zilla::Role::MetaProvider::Provider';

has _pm_files     => ( isa => ArrayRef, ro, lazy_build, );
has _package_data => ( isa => ArrayRef, ro, lazy_build, );

sub _build__pm_files {
  shift->zilla->files->grep( sub { $_[0]->name =~ m{\.pm$} } );
}

sub _build__package_data {
  my $self  = shift;
  my @files = $self->_pm_files->flatten;
  @files = map {
    my ( $filename, $content ) = ( $_->name, $_->content );
    $self->_packages_for( $filename, $content );
  } @files;
  \@files;
}

sub _packages_for {
  my ( $self, $filename, $content ) = @_;
  my $version = Module::Extract::VERSION->parse_version_safely($filename);
  return
    map { +{ module => $_, filename => $filename, version => $version, } }
    Module::Extract::Namespaces->from_file($filename);
}

sub provides {
  my ( $self, %discovered );
  %discovered = ();
  $self       = shift;

  for ( $self->_package_data->flatten ) {
    $discovered{ $_->{module} } = {
      file => $_->{filename},
      $self->_resolve_version( $_->{version} ),
    };
  }
  return \%discovered;
}

__PACKAGE__->meta->make_immutable;
1;

