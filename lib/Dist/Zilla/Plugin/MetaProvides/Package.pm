package Dist::Zilla::Plugin::MetaProvides::Package;
our $VERSION = '1.092000';


# ABSTRACT: Extract namespaces/version from traditional packages for provides
#
# $Id:$
use strict;
use warnings;
use Moose;
use Moose::Autobox;
use MooseX::Has::Sugar;
use MooseX::Types::Moose             (':all');
use Dist::Zilla::MetaProvides::Types (':all');

use aliased 'Module::Extract::VERSION'                 => 'Version',    ();
use aliased 'Module::Extract::Namespaces'              => 'Namespaces', ();
use aliased 'Dist::Zilla::MetaProvides::ProvideRecord' => 'Record',     ();

use namespace::autoclean;
with 'Dist::Zilla::Role::MetaProvider::Provider';

sub _packages_for {
  my ( $self, $filename, $content ) = @_;
  my $version   = Version->parse_version_safely($filename);
  my $to_record = sub {
    Record->new(
      module  => $_,
      file    => $filename,
      version => $version,
      parent  => $self,
    );
  };
  return [ Namespaces->from_file($filename) ]->map($to_record)->flatten;
}

sub provides {
  my $self        = shift;
  my $perl_module = sub { $_->name =~ m{\.pm$} };
  my $get_records = sub {
    $self->_packages_for( $_->name, $_->content );
  };

  return $self->zilla->files->grep($perl_module)->map($get_records)->flatten;
}


__PACKAGE__->meta->make_immutable;
1;


__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::MetaProvides::Package - Extract namespaces/version from traditional packages for provides

=head1 VERSION

version 1.092000

=head1 SEE ALSO

=over 4

=item * L<Dist::Zilla::Plugin::MetaProvides>

=back

=head1 AUTHOR

  Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Kent Fredric.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


