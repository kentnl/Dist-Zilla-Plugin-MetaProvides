package Dist::Zilla::MetaProvides::ProvideRecord;

# $Id:$
use strict;
use warnings;
use Moose;
use MooseX::Types::Moose             (':all');
use Dist::Zilla::MetaProvides::Types (':all');
use List::MoreUtils                  ('all');
use Moose::Autobox;
use MooseX::Has::Sugar;

use namespace::autoclean;

has version => ( isa => ModVersion, ro, required );
has module  => ( isa => Str,        ro, required );
has file    => ( isa => Str,        ro, required );
has parent => ( ro, required,
  handles => [ 'zilla', '_resolve_version', ],
  isa     => 'Dist::Zilla::Role::MetaProvider::Provider',
);

sub copy_into {
  my $self  = shift;
  my $dlist = shift;
  $dlist->{ $self->module } = {
    file => $self->file,
    $self->_resolve_version( $self->version ),
  };
}

1;

