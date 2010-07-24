use strict;
use warnings;

package Dist::Zilla::Role::MetaProvider::Provider;
BEGIN {
  $Dist::Zilla::Role::MetaProvider::Provider::VERSION = '1.11034201';
}

# ABSTRACT: A Role for Metadata providers specific to the 'provider' key.

# $Id:$
use Moose::Role;
use MooseX::Types::Moose (':all');
use namespace::autoclean;


with 'Dist::Zilla::Role::MetaProvider';


requires 'provides';


has inherit_version => (
  is            => 'ro',
  isa           => Bool,
  default       => 1,
  documentation => 'Whether or not to treat the global version as an authority',
);


has inherit_missing => (
  is            => 'ro',
  isa           => Bool,
  default       => 1,
  documentation => 'How to behave when we are trusting modules to have versions and one is missing one',
);


sub _resolve_version {
  my $self    = shift;
  my $version = shift;
  if ( $self->inherit_version or ( $self->inherit_missing and not defined $version ) ) {
    return ( 'version', $self->zilla->version );
  }
  if ( not defined $version ) {
    return ();
  }
  return ( 'version', $version );
}


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


__END__
=pod

=head1 NAME

Dist::Zilla::Role::MetaProvider::Provider - A Role for Metadata providers specific to the 'provider' key.

=head1 VERSION

version 1.11034201

=head1 PERFORMS ROLES

L<Dist::Zilla::Role::MetaProvider>

=head1 REQUIRED METHODS FOR PERFORMING ROLES

=head2 provides

Must return an array full of L<Dist::Zilla::MetaProvider::ProvideRecord>
instances.

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

=head1 PUBLIC METHODS

=head2 metadata

Fullfills the requirement of L<Dist::Zilla::Role::MetaProvider> by processing
results returned from C<$self-E<gt>provides>.

=head1 SEE ALSO

=over 4

=item * L<Dist::Zilla::Role::MetaProvider>

=item * L<Dist::Zilla::Plugin::MetaProvider>

=item * L<Dist::Zilla::MetaProvider::ProvideRecord>

=back

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Kent Fredric.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

