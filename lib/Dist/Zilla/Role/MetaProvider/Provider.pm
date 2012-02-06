use strict;
use warnings;

package Dist::Zilla::Role::MetaProvider::Provider;

# ABSTRACT: A Role for Metadata providers specific to the 'provider' key.

# $Id:$
use Moose::Role;
use MooseX::Types::Moose (':all');
use Dist::Zilla::Util::EmulatePhase 0.01000101 qw( get_metadata );
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
  is            => 'ro',
  isa           => Bool,
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
  is            => 'ro',
  isa           => Bool,
  default       => 1,
  documentation => 'How to behave when we are trusting modules to have versions and one is missing one',
);

=head2 meta_noindex

This dictates how to behave when a discovered class is also present in the C<no_index> META field.

=head3 values

=over 4

=item * Set to "0" B<[default]>

C<no_index> META field will be ignored

=item * Set to "1"

C<no_index> META field will be recognised and things found in it will cause respective packages
to not be provided in the metadata.

=back

=cut

has meta_noindex => (
  is            => 'ro',
  isa           => Bool,
  default       => 1,
  documentation => 'Scan for the meta_noindex metadata key and do not add provides records for things in it',
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

=head2 _try_regen_metadata

This is a nasty hack really, to work around the way L<< C<Dist::Zilla>|Dist::Zilla >> handles
metaproviders, which result in meta-data being inaccessible to metadata Plugins.

  my $meta  = $object->_try_regen_metadata()

This at present returns metadata provided by  L<< C<MetaNoIndex>|Dist::Zilla::Plugin::MetaNoIndex >> ( if present )
but will be expanded as needed.

If you have a module you think should be in this list, contact me, or file a bug, I'll do my best =)

=cut

sub _try_regen_metadata {
  my ($self) = @_;
  return get_metadata(
    {
      zilla => $self->zilla,
      isa   => [qw( =MetaNoIndex )]
    }
  );
}

=head2 _apply_meta_noindex

This is a utility method to make performing classes life easier in skipping no_index entries.

  my @filtered_provides = $self->_apply_meta_noindex( @provides )

is the suggested use.

Returns either an empty list, or a list of ProvideRecord's

=cut

sub _apply_meta_noindex {
  my ( $self, @items ) = @_;

  # meta_noindex application is disabled
  if ( not $self->meta_noindex ) {
    return @items;
  }

  my $meta = $self->_try_regen_metadata;

  if ( not keys %{$meta} or not exists $meta->{no_index} ) {
    $self->log_debug( q{No no_index attribute found while trying to apply meta_noindex for} . $self->plugin_name );
    return @items;
  }
  else {
    $self->log_debug(q{no_index found in metadata, will apply rules});
  }

  my $noindex = $meta->{'no_index'};
  my ( $files, $dirs, $packages, $namespaces ) = ( [], [], [], [] );
  $files      = $noindex->{'file'}      if exists $noindex->{'file'};
  $dirs       = $noindex->{'dir'}       if exists $noindex->{'dir'};
  $dirs       = $noindex->{'directory'} if exists $noindex->{'directory'};
  $packages   = $noindex->{'package'}   if exists $noindex->{'package'};
  $namespaces = $noindex->{'namespace'} if exists $noindex->{'namespace'};

  for my $file ( @{$files} ) {
    @items = grep { $_->file ne $file } @items;
  }
  for my $module ( @{$packages} ) {
    @items = grep { $_->module ne $module } @items;
  }
  for my $dir ( @{$dirs} ) {
    ## no critic (RegularExpressions ProhibitPunctuationVars)
    @items = grep { $_->file !~ qr{^\Q$dir\E($|/)} } @items;
  }
  for my $namespace ( @{$namespaces} ) {
    ## no critic (RegularExpressions ProhibitPunctuationVars)
    @items = grep { $_->module !~ qr{^\Q$namespace\E($|::)} } @items;
  }
  return @items;
}

=head1 PUBLIC METHODS

=head2 metadata

Fulfills the requirement of L<Dist::Zilla::Role::MetaProvider> by processing
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

=head1 THANKS

=over 4

=item * Thanks to David Golden ( xdg / DAGOLDEN ) for the suggestion of the no_index feature
for compatibility with MetaNoIndex plugin.

=back

=cut

no Moose::Role;

1;

