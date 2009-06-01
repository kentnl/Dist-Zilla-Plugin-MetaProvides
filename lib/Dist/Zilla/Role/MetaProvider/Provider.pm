package Dist::Zilla::Role::MetaProvider::Provider;

# $Id:$
use strict;
use warnings;
use Moose::Role;

use namespace::autoclean;

with 'Dist::Zilla::Role::MetaProvider';

requires '_provides';

=head2 inherit_version

This dictates how to report versions.

Default behavior is set to 1.

Setting this value to '1' makes the version defined in C<dist.ini>
the authority, and all versions discovered in packages are ignored.

Setting this value to '0' makes the version defined in the discovered class
the authority, and it is copied to the provides metadata.

This option also controls data in the extra_files list.

=cut

has inherit_version => (
  isa           => 'Bool',
  is            => 'ro',
  default       => 1,
  documentation => 'Whether or not to treat the global version as an authority',
);

=head2 inherit_missing

This dictates how to react when a class is discovered ( or defined in the INI file )
but a version is not specified.

Setting this value to "0" results in the provides list having no specified version,
which is permissible.

Setting this value to "1" ( the default ) results in dist.ini's version being used
instead.

=cut

has inherit_missing => (
  isa     => 'Bool',
  is      => 'ro',
  default => 1,
  documentation =>
    'How to behave when we are trusting modules to have versions and one is'
    . ' missing one',
);

sub _resolve_version {
  my $self    = shift;
  my $version = shift;
  if ( $self->inherit_version
    or ( $self->inherit_missing and not defined $version ) )
  {
    return ( 'version', $self->zilla->version );
  }
  if ( not defined $version ) {
    return ();
  }
  return ( 'version', $version );
}

sub metadata {
  my ($self) = @_;
  return { provides => $self->_provides };
}

no Moose;
1;

