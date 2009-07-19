package Dist::Zilla::Plugin::MetaProvides::Class;
our $VERSION = '1.092000';


# ABSTRACT: Scans Dist::Zilla's .pm files and tries to identify classes using Class::Discover.

# $Id:$
use strict;
use warnings;
use Moose;
use Moose::Autobox;
use MooseX::Has::Sugar;
use MooseX::Types::Moose             (':all');
use Dist::Zilla::MetaProvides::Types (':all');
use Class::Discover                  ();

use aliased 'Dist::Zilla::MetaProvides::ProvideRecord' => 'Record', ();

use namespace::autoclean;
with 'Dist::Zilla::Role::MetaProvider::Provider';

sub _classes_for {
  my ( $self, $filename, $content ) = @_;
  my ($scanparams) = {
    keywords => {
      class => 1,
      role  => 1,
    },
    files => [$filename],
    file  => $filename,
  };
  my $to_record = sub {
    Record->new(
      module  => $_->keys->at(0),
      file    => $filename,
      version => $_->values->at(0)->{version},
      parent  => $self,
    );
  };
  return [ Class::Discover->_search_for_classes_in_file( $scanparams, \$content ) ]->map($to_record)->flatten;
}

sub provides {
  my $self        = shift;
  my $perl_module = sub { $_->name =~ m{\.pm$} };
  my $get_records = sub {
    $self->_classes_for( $_->name, $_->content );
  };

  return $self->zilla->files->grep($perl_module)->map($get_records)->flatten;

}


__PACKAGE__->meta->make_immutable;
1;


__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::MetaProvides::Class - Scans Dist::Zilla's .pm files and tries to identify classes using Class::Discover.

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


