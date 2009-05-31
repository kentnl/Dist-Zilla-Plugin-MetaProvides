package Dist::Zilla::Plugin::MetaProvides;
# ABSTRACT: use Class::Discover to define 'provides' for distribution metadata
use Moose;
with 'Dist::Zilla::Role::MetaProvider';

use Class::Discover;
use Path::Class qw( dir file );
use File::Find::Rule ();
use File::Find::Rule::Perl ();

=head1 DESCRIPTION

This plugin automatically adds 'provides' entries to distribution metadata.
You can add your own if the scanner can't work it out.

  [MetaProvides]

or

  [MetaProvides]
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

has extra_files => (
  is       => 'ro',
  isa      => 'Str',
);

has extra_files_reader_class => (
  isa => 'Dist::Zilla::Config',
  is  => 'ro',
  default => 'Dist::Zilla::Config::INI',
);

has inherit_version => (
  isa => 'Bool',
  is  => 'ro',
  default => 1,
);

has inherit_missing => (
  isa => 'Bool',
  is  => 'ro',
  default => 1,
);

has _module_dirs => (
  is       => 'ro',
  isa      => 'ArrayRef',
  lazy_build => 1,
);


has _extra_files_reader => (
  isa => 'Object',
  is  => 'ro',
  lazy_build => 1,
);

has _scan_list => (
  isa => 'ArrayRef',
  is  => 'ro',
  lazy_build => 1,
);

sub _build__module_dirs {
  # Todo : Ask Zilla about where these are.
  return [ 'lib',];
}

sub _build__scan_list {
  # Todo: Ask Zilla for these.
  my ($self) = shift;
  my @files = File::Find::Rule->perl_module->in(@{ $self->_module_dirs });
}

sub _build_extra_files_reader {
  my ($self) = shift;
  eval "require " . $self->extra_files_reader_class . "; 1" or die;
  return $self->extra_files_reader_class->new();
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

Solution Pending.

=cut

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
