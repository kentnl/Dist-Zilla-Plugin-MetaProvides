use strict;
use warnings;
package Dist::Zilla::MetaProvides::Types;
our $VERSION = '1.10000417';


# ABSTRACT: Utility Types for the MetaProvides Plugin
#
# $Id:$
use Moose ();
use MooseX::Types::Moose (':all');
use MooseX::Types -declare => [ 'ModVersion', 'ProviderObject', ];


subtype ModVersion, as Str | Undef;


subtype ProviderObject, as Object, where { $_->does('Dist::Zilla::Role::MetaProvider::Provider') };


1;


__END__

=pod

=head1 NAME

Dist::Zilla::MetaProvides::Types - Utility Types for the MetaProvides Plugin

=head1 VERSION

version 1.10000417

=head1 SUBTYPES

=head2 ModVersion

Module Versions can be either a string, or an undef.

In L<Dist::Zilla::MetaProvides::ProvideRecord> and
L<Dist::Zilla::Role::MetaProvider::Provider>, versions that have a value of
undef will be trimmed from output.



=head2 ProviderObject

Just an easy to use Check that assures a given object performs a role.



=head1 SEE ALSO

=over 4

=item * L<MooseX::Types::Moose>

=item * L<Moose::Util::TypeConstraints>

=item * L<Dist::Zilla::MetaProvides::ProvideRecord>

=item * L<Dist::Zilla::Role::MetaProvider::Provider>

=back 



=head1 AUTHOR

  Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Kent Fredric.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 


