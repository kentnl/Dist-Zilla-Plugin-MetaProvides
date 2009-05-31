package Dist::Zilla::Plugin::ProvidesClass;
# ABSTRACT: use Class::Discover to define 'provides' for distribution metadata
use Moose;
with 'Dist::Zilla::Role::MetaProvider';

use Class::Discover;

=head1 DESCRIPTION

This plugin automatically adds 'provides' entries to distribution metadata.
You can add your own if the scanner can't work it out.

  [ProvidesClass]

or

  [ProvidesClass]
  extra_files = dist_provides_class.ini

  ; See Below for details
  extra_files_reader_class = Dist::Zilla::Config::INI
  inherit_version = false
  inherit_missing = true


=head2 extra_files

With Dist::Zilla::Config::INI, the format is as follows.

  [Some::Package]
  file = /lib/Some/Package.pm
  version = 0.03

  [Other::Package]
  file = /lib/Other/Package.pm

Entries found in this file will over-write anything discovered.

=head3 file

Mandatory parameter, path to file relative to distribution root.

=head3 version

Optional Parameter, package version. Behaviour dictated by C<inherit_version>
and C<inherit_missing>

=head2 extra_files_reader_class

package to create an instance of to read the configuration.

must perform L<Dist::Zilla::Config>

=head2 inherit_version

This dictates how to report versions.

Default behavior is set to true.

Setting this value to 'true' makes the version defined in C<dist.ini>
the authority, and all versions discovered in packages are ignored.

Setting this value to 'false' makes the version defined in the discovered class
the authority, and it is copied to the provides metadata.

This option also controls data in the extra_files list.

=head2 inherit_missing

This dictates how to react when a class is discovered ( or defined in the INI file )
but a version is not specified.

Setting this value to "false" results in the provides list having no specified version,
which is permissible.

Setting this value to "true" ( the default ) results in dist.ini's version being used
instead.

=cut

has resources => (
  is       => 'ro',
  isa      => 'HashRef',
  required => 1,
);

sub new {
  my ($class, $arg) = @_;

  my $self = $class->SUPER::new({
    '=name'   => delete $arg->{'=name'},
    zilla     => delete $arg->{zilla},
    resources => $arg,
  });
}

sub metadata {
  my ($self) = @_;

  return { resources => $self->resources };
}

=head1 IMPORTANT / BUGS

At present, due to how L<Class::Discover> works and how "provides" is handled by CPAN,
using this feature will by default only index files that L<Class::Discover> can discover,
which is files containing classes defined with L<MooseX::Declare>.

This means, that, if you happen to have B<NON> L<MooseX::Declare> packages, you will have to
index their metadata by hand using C<extra_files>
( or at least the file <-> package corelation map ), or they won't show up on CPAN.

=cut

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
