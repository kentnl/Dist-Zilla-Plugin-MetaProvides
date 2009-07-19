package Dist::Zilla::MetaProvides::ProvideRecord;
our $VERSION = '1.092000';


# ABSTRACT: Data Management Record for MetaProvider::Provides Based Class

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


has module => ( isa => Str, ro, required );


has file => ( isa => Str, ro, required );


has parent => ( ro, required, weak_ref,
    isa     => ProviderObject,
    handles => [ 'zilla', '_resolve_version', ],
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


__END__

=pod

=head1 NAME

Dist::Zilla::MetaProvides::ProvideRecord - Data Management Record for MetaProvider::Provides Based Class

=head1 VERSION

version 1.092000

=head1 ATTRIBUTES

=head2 version

See L<Dist::Zilla::MetaProvides::Types/ModVersion>

=head2 module

The String Name of a fully qualified module to be reported as
included in the distribution.

=head2 file

The String Name of the file as to be reported in the distribution.

=head2 parent

A L<Dist::Zilla::MetaProvides::Types/ProviderObject>, mostly to get Zilla information
and accessors from L<Dist::Zilla::Role::MetaProvider::Provider>

=head1 METHODS

=head2 copy_into C<( \%provides_list )>

Populate the referenced C<%provides_list> with data from this Provide Record object.

This is called by the  L<Dist::Zilla::Role::MetaProvider::Provider> Role.

This is very convenient if you have an array full of these objects, for you can just do

    my %discovered;
    for ( @array ) {
       $_->copy_into( \%discovered );
    }

and C<%discovered> will be populated with relevant data.

=head1 AUTHOR

  Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Kent Fredric.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


