use 5.006;
use strict;
use warnings;

package Dist::Zilla::MetaProvides::ProvideRecord;

our $VERSION = '2.001002';

# ABSTRACT: Data Management Record for MetaProvider::Provides Based Class

# AUTHORITY

use Moose qw( has );
use MooseX::Types::Moose qw( Str );
use Dist::Zilla::MetaProvides::Types qw( ModVersion ProviderObject );

use namespace::autoclean;

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::MetaProvides::ProvideRecord",
    "interface":"class",
    "inherits":"Moose::Object"
}

=end MetaPOD::JSON

=cut

=attr version

See L<Dist::Zilla::MetaProvides::Types/ModVersion>

=cut

has version => ( isa => ModVersion, is => 'ro', required => 1 );

=attr module

The String Name of a fully qualified module to be reported as
included in the distribution.

=cut

has module => ( isa => Str, is => 'ro', required => 1 );

=attr file

The String Name of the file as to be reported in the distribution.

=cut

has file => ( isa => Str, is => 'ro', required => 1 );

=attr parent

A L<Dist::Zilla::MetaProvides::Types/ProviderObject>, mostly to get Zilla information
and accessors from L<Dist::Zilla::Role::MetaProvider::Provider>

=cut

has parent => (
  is       => 'ro',
  required => 1,
  weak_ref => 1,
  isa      => ProviderObject,
  handles  => [ 'zilla', '_resolve_version', ],
);

=method copy_into C<( \%provides_list )>

Populate the referenced C<%provides_list> with data from this Provide Record object.

This is called by the  L<Dist::Zilla::Role::MetaProvider::Provider> Role.

This is very convenient if you have an array full of these objects, for you can just do

    my %discovered;
    for ( @array ) {
       $_->copy_into( \%discovered );
    }

and C<%discovered> will be populated with relevant data.

=cut

sub copy_into {
  my $self  = shift;
  my $dlist = shift;
  $dlist->{ $self->module } = {
    file => $self->file,
    $self->_resolve_version( $self->version ),
  };
  return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 QUICK REFERENCE

  ->new(options={})
    version => ^attr
    module  => ^attr
    file    => ^attr
    parent  => ^attr

  ->version                         # ModVersion
  ->module                          # Str
  ->file                            # Str
  ->parent                          # ProviderObject
  ->zilla                           # DZil
                                    # - via parent
  ->_resolve_version($pkgversion)   # ( 'version', $resolved )
                                    # - via parent
  ->copy_into( $hash )

=over 4

=item * C<ProviderObject> : L<<
C<Dist::Zilla::MetaProvides::Types>
|Dist::Zilla::MetaProvides::Types/ProviderObject
>>

=item * C<ProviderObject> : L<<
C<Dist::Zilla::Role::MetaProvider::Provider>
|Dist::Zilla::Role::MetaProvider::Provider
>>

=item * C<ModVersion> : L<<
C<Dist::Zilla::MetaProvides::Types>
|Dist::Zilla::MetaProvides::Types/ModVersion
>>

=back

=cut
