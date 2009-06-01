package Dist::Zilla::Plugin::MetaProvides::Class;

# $Id:$
use strict;
use warnings;
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose (':all');
use Moose::Autobox;
use Class::Discover ();

use namespace::autoclean;
with 'Dist::Zilla::Role::MetaProvider::Provider';

has _pm_files   => ( isa => ArrayRef, ro, lazy_build, );
has _class_data => ( isa => ArrayRef, ro, lazy_build, );

sub _build__pm_files {
  shift->zilla->files->grep( sub { $_[0]->name =~ m{\.pm$} } );
}

sub _build__class_data {
  my $self  = shift;
  my @files = $self->_pm_files->flatten;
  @files = map {
    my ( $filename, $content ) = ( $_->name, $_->content );
    map {
      +{
        module => $_->keys->at(0),
        %{ $_->values->at(0) },
        filename => $filename,
        }
    } $self->_classes_for( $filename, $content );
  } @files;
  \@files;
}

sub _classes_for {
  my ( $self, $filename, $content ) = @_;
  my ($scanparams) = {
    keywords => {
      class => 1,
      role  => 1,
    },
    files => [$filename],
    file  => $filename,
  };
  my @results =
    Class::Discover->_search_for_classes_in_file( $scanparams, \$content );
  return @results;
}

sub provides {
  my ( $self, %discovered );
  %discovered = ();
  $self       = shift;

  for ( $self->_class_data->flatten ) {
    $discovered{ $_->{module} } = {
      file => $_->{filename},
      $self->_resolve_version( $_->{version} ),
    };
  }
  return \%discovered;
}

__PACKAGE__->meta->make_immutable;
1;

