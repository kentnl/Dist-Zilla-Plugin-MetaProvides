package Dist::Zilla::MetaProvides::Class;

# $Id:$
use strict;
use warnings;
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose (':all');
use Moose::Autobox;
use Class::Discover          ();
use MooseX::AttributeHelpers ();

use namespace::autoclean;
with 'Dist::Zilla::Role::MetaProvider::Provider';

has _pm_files_list => (
  isa => ArrayRef,
  ro, lazy_build,
  metaclass => 'Collection::Array',
  provides  => { elements => '_pm_files', }
);

sub _build__pm_files_list {
  shift->zilla->files->grep( sub { $_[0]->name =~ m{\.pm$} } );
}

sub _classes_for {
    my ( $self, $filename, $content ) = @_;
    my ( $scanparams ) = {
      keywords => {
        class => 1,
        role  => 1,
      },
      files => [$filename],
      file  => $filename,
    };
    my @results = Class::Discover->_search_for_classes_in_file( $scanparams, \$content );
    return @results || ();
}

sub _resolve_version {
    my $self = shift;
    my $version = shift;
    if ( $self->inherit_version or ( $self->inherit_missing and not defined $version ) ){
        return $self->zilla->version;
    }
    return $version;
}

sub _provides {
  my ( $self, %discovered );
  $self = shift;
  for ( $self->_pm_files ) {
    my ( $filename, $content ) = ( $_->name, $_->content );
    my ( @results ) = $self->_classes_for( $filename, $content );
    next if not @results;
    for my $result ( @results ){
        for my $module ( keys %{$result} ){
            $discovered{$module} ||= {};
            $discovered{$module}->{file} = $filename;
            my $resolved_version = $self->_resolve_version( $result->{$module}->{version} );
            $discovered{$module}->{version} = $resolved_version if defined $resolved_version;
        }
    }
  }
  return \%discovered;
}

1;

