package Dist::Zilla::Plugin::MetaProvides::FromFile;
our $VERSION = '1.092000';


# ABSTRACT: In the event nothing else works, pull in hand-crafted metadata from a specified file.
#
# $Id:$
use strict;
use warnings;
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose (':all');
use Moose::Autobox;
use Carp                ();
use Config::INI::Reader ();
use aliased 'Dist::Zilla::MetaProvides::ProvideRecord' => 'Record', ();

use namespace::autoclean;
with 'Dist::Zilla::Role::MetaProvider::Provider';

has file        => ( isa => Str,       ro, required, );
has reader_name => ( isa => ClassName, ro, default => 'Config::INI::Reader', );
has _reader     => ( isa => Object,    ro, lazy_build, );

sub _build__reader {
  my ($self) = shift;
  eval "require " . $self->reader_name . "; 1;" or die;
  return $self->reader_name->new();
}

sub provides {
  my $self      = shift;
  my $conf      = $self->_reader->read_file( $self->file );
  my $to_record = sub {
    Record->new(
      module  => $_,
      file    => $conf->{$_}->{file},
      version => $conf->{$_}->{version},
      parent  => $self,
    );
  };
  return $conf->keys->map($to_record)->flatten;
}


__PACKAGE__->meta->make_immutable;
1;


__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::MetaProvides::FromFile - In the event nothing else works, pull in hand-crafted metadata from a specified file.

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


