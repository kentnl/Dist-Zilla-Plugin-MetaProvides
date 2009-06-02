package Dist::Zilla::Role::MetaProvider::Provider;

# ABSTRACT: A Role for Metadata providers specific to the 'provider' key.

# $Id:$
use strict;
use warnings;
use Moose::Role;

use namespace::autoclean;

=head1 PERFORMS ROLES

L<Dist::Zilla::Role::MetaProvider>

=cut

with 'Dist::Zilla::Role::MetaProvider';

=head1 REQUIRED METHODS FOR PERFORMING ROLES

=head2 provides

Must return an array full of L<Dist::Zilla::MetaProvider::ProvideRecord>
instances.

=cut

requires 'provides';

=head1 ATTRIBUTES / PARAMETERS

=head2 inherit_version

This dictates how to report versions.

Default behavior is set to 1.

Setting this value to '1' makes the version defined in C<dist.ini>
the authority, and all versions discovered in packages are ignored.

Setting this value to '0' makes the version defined in the discovered class
the authority, and it is copied to the provides metadata.

( To use this feature in a performing class, see L</_resolve_version> )

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

( To use this feature in a performing class, see L</_resolve_version> )

=cut

has inherit_missing => (
  isa     => 'Bool',
  is      => 'ro',
  default => 1,
  documentation =>
    'How to behave when we are trusting modules to have versions and one is'
    . ' missing one',
);

=head1 PRIVATE METHODS

=head2 _resolve_version

This is a utility method to make performing classes life easier in adhering to
user requirements.

    my $params  = {
        file => $somefile ,
        $self->_resolve_version( $version );
    }

is the suggested used.

Returns either an empty list, or a list with C<('version', $version )>;

This is so C<{ version => undef }> does not occur in the YAML.

=cut

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

=head1 PUBLIC METHODS

=head2 metadata

Fullfills the requirement of L<Dist::Zilla::Role::MetaProvider> by processing
results returned from C<$self->provides>.

=cut

sub metadata {
  my ($self) = @_;
  my $discover = {};
  for ( $self->provides ) {
    $_->copy_into($discover);
  }
  return { provides => $discover };
}

no Moose;
1;

