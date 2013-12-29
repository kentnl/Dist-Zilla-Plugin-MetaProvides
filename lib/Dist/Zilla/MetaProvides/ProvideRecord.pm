use strict;
use warnings;

package Dist::Zilla::MetaProvides::ProvideRecord;
BEGIN {
  $Dist::Zilla::MetaProvides::ProvideRecord::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::MetaProvides::ProvideRecord::VERSION = '10.10000000';
}

# ABSTRACT: Data Management Record for MetaProvider::Provides Based Class

use Moose;
use MooseX::Types::Moose             (':all');
use Dist::Zilla::MetaProvides::Types (':all');

use namespace::autoclean;



has version => ( isa => ModVersion, is => 'ro', required => 1 );


has module => ( isa => Str, is => 'ro', required => 1 );


has file => ( isa => Str, is => 'ro', required => 1 );


has parent => (
  is       => 'ro',
  required => 1,
  weak_ref => 1,
  isa      => ProviderObject,
  handles  => [ 'zilla', '_resolve_version', ],
);


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

__END__

=pod

=head1 NAME

Dist::Zilla::MetaProvides::ProvideRecord - Data Management Record for MetaProvider::Provides Based Class

=head1 VERSION

version 10.10000000

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::MetaProvides::ProvideRecord",
    "interface":"class",
    "inherits":"Moose::Object"
}


=end MetaPOD::JSON

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

This software is copyright (c) 2013 by Kent Fredric.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
