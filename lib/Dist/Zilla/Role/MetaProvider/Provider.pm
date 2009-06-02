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

=head3 values

=over 4

=item * Set to "1" B<[default]>
The version defined by L<Dist::Zilla> is the authority, and all versions
discovered in packages are ignored.

=item * Set to "0"
The version defined in the discovered class is the authority, and it is copied
to the provides metadata.

=back

( To use this feature in a performing class, see L</_resolve_version> )

=cut

has inherit_version => (
  isa           => 'Bool',
  is            => 'ro',
  default       => 1,
  documentation => 'Whether or not to treat the global version as an authority',
);

=head2 inherit_missing

This dictates how to react when a class is discovered but a version is not
specified.

=head3 values

=over 4

=item * Set to "1" B<[default]>
C<dist.ini>'s version turns up in the final metadata.

=item * Set to "0".
A C<provide> turns up in the final metadata without a version, which is permissible.

=back

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

is the suggested use.

Returns either an empty list, or a list with C<('version', $version )>;

This is so C<{ version =E<gt> undef }> does not occur in the YAML.

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
results returned from C<$self-E<gt>provides>.

=cut

sub metadata {
  my ($self) = @_;
  my $discover = {};
  for ( $self->provides ) {
    $_->copy_into($discover);
  }
  return { provides => $discover };
}

=head1 SEE ALSO

=over 4

=item * L<Dist::Zilla::Role::MetaProvider>

=item * L<Dist::Zilla::Plugin::MetaProvider>

=item * L<Dist::Zilla::MetaProvider::ProvideRecord>

=back

=cut

no Moose;
1;

