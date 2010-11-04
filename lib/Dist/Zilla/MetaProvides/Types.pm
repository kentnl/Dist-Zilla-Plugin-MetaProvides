use strict;
use warnings;

package Dist::Zilla::MetaProvides::Types;

# ABSTRACT: Utility Types for the MetaProvides Plugin
#
# $Id:$
use Moose ();
use MooseX::Types::Moose (':all');
use MooseX::Types -declare => [ 'ModVersion', 'ProviderObject', ];

=head1 SUBTYPES

=head2 ModVersion

Module Versions can be either a string, or an undef.

In L<Dist::Zilla::MetaProvides::ProvideRecord> and
L<Dist::Zilla::Role::MetaProvider::Provider>, versions that have a value of
undef will be trimmed from output.

=cut

subtype ModVersion, as Str | Undef;

=head2 ProviderObject

Just an easy to use Check that assures a given object performs a role.

=cut

subtype ProviderObject, as Object, where { $_->does('Dist::Zilla::Role::MetaProvider::Provider') };

=head1 SEE ALSO

=over 4

=item * L<MooseX::Types::Moose>

=item * L<Moose::Util::TypeConstraints>

=item * L<Dist::Zilla::MetaProvides::ProvideRecord>

=item * L<Dist::Zilla::Role::MetaProvider::Provider>

=back

=cut

1;

