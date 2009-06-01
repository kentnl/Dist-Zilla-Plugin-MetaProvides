package Dist::Zilla::Plugin::MetaProvides;

# ABSTRACT: use Class::Discover to define 'provides' for distribution metadata
use Moose;
with 'Dist::Zilla::Role::MetaProvider';

use Class::Discover             ();
use Module::Extract::Namespaces ();
use Module::Extract::VERSION    ();
use Carp                        ();
use Config::INI::Reader         ();

=head1 DESCRIPTION

This plugin automatically adds 'provides' entries to distribution metadata.
You can add your own if the scanner can't work it out.

  [MetaProvides]

or

  [MetaProvides]
  extra_files = dist_provides_class.ini

  ; See Below for details
  extra_files_reader_class = Config::INI::Reader
  inherit_version = false
  inherit_missing = true

=cut

=head2 extra_files

With Config::INI::Reader, the format is as follows.

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

=cut

has extra_files => (
  is            => 'ro',
  isa           => 'Str',
  documentation => 'A name of a file to read supplementary version/package'
    . ' info from',
  predicate => 'has_extra_files',
);

=head2 extra_files_reader_class

package to create an instance of to read the configuration.

must do ->read_file

=cut

has extra_files_reader_class => (
  isa     => 'ClassName',
  is      => 'ro',
  default => 'Config::INI::Reader',
  documentation =>
    'The name of a class that can be instantiated to parse the file specified'
    . ' in extra_files',
);

=head2 inherit_version

This dictates how to report versions.

Default behavior is set to 1.

Setting this value to '1' makes the version defined in C<dist.ini>
the authority, and all versions discovered in packages are ignored.

Setting this value to '0' makes the version defined in the discovered class
the authority, and it is copied to the provides metadata.

This option also controls data in the extra_files list.

=cut

has inherit_version => (
  isa           => 'Bool',
  is            => 'ro',
  default       => 1,
  documentation => 'Whether or not to treat the global version as an authority',
);

=head2 inherit_missing

This dictates how to react when a class is discovered ( or defined in the INI file )
but a version is not specified.

Setting this value to "0" results in the provides list having no specified version,
which is permissible.

Setting this value to "1" ( the default ) results in dist.ini's version being used
instead.

=cut

has inherit_missing => (
  isa     => 'Bool',
  is      => 'ro',
  default => 1,
  documentaiton =>
    'How to behave when we are trusting modules to have versions and one is'
    . ' missing one',
);

has _extra_files_reader => (
  isa           => 'Object',
  is            => 'ro',
  lazy_build    => 1,
  documentation => 'An entity that is created to parse our configuration',
);

has _scan_list => (
  isa           => 'ArrayRef',
  is            => 'ro',
  lazy_build    => 1,
  documentation => 'A list of files to attempt version/class extraction from',
);

has _scanned_data => (
  isa           => 'HashRef',
  is            => 'ro',
  lazy_build    => 1,
  documentation => 'HashRef of data aggregated from files',
);

has _extra_files_data => (
  isa           => 'HashRef',
  is            => 'ro',
  lazy_build    => 1,
  documentation => 'User Specified data read from configs',
);

has _provides => (
  isa           => 'HashRef',
  is            => 'ro',
  lazy_build    => 1,
  documentation => 'Aggregated Pool for provide data ',
);

sub _build__scan_list {

  my ($self) = shift;
  my @files = grep { $_->name =~ m{\.pm$} } @{ $self->zilla->files };
  \@files;
}

sub _build__extra_files_reader {

  # TODO : Get rid of pesky runtime stringy eval thing
  my ($self) = shift;
  eval "require " . $self->extra_files_reader_class . "; 1" or die;
  return $self->extra_files_reader_class->new();
}

sub _expand_file {
  my ( $self, $file ) = @_;
  return ( $file->name, $file->content );
}

sub _cd_scan_file {

  # TODO : Get ASH to make Class::Discover support scalar-refs
  my ( $self,     $file )    = @_;
  my ( $filename, $content ) = $self->_expand_file($file);
  my (%output);

  # this is untill Class::Discover can take a scalar ref
  my $scanparams = {
    keywords => {
      class => 1,
      role  => 1,
    },
    files => [$filename],
    file  => $filename,
  };

  # TODO : Delete this crap code when a better way exists
  for my $entry (
    Class::Discover->_search_for_classes_in_file( $scanparams, \$content ) )
  {

    $self->logstate($entry);

    for my $module ( keys %{$entry} ) {
      $output{$module}->{file} = $filename;
      next unless exists $entry->{$module}->{version};
      $output{$module}->{version} = $entry->{$module}->{version};
    }
  }
  return ( scalar keys %output ) ? \%output : undef;
}

sub _extract_scan_file {

  # TODO : Support using \$content
  # TODO : Get b d foy to let M:E:N and M:E:V to support scalar refs.

  my ( $self,     $file )    = @_;
  my ( $filename, $content ) = $self->_expand_file($file);

  my %namespaces =
    map { $_ => 1 } Module::Extract::Namespaces->from_file($filename);
  $self->logstate(%namespaces);
  return undef if ( not scalar keys %namespaces );

  my $version = Module::Extract::VERSION->parse_version_safely($filename);

  my %output = ();
  for ( keys %namespaces ) {
    $self->logstate("$_");
    $output{$_} = { file => $filename };
    if ( defined $version ) {
      $output{$_}->{'version'} = $version;
    }
  }
  return \%output;
}

sub _scan_file {
  my ( $self, $file ) = @_;

  # MX Family
  my $d;
  return $d if ( $d = $self->_cd_scan_file($file) );

  # Everything Else
  return $d if ( $d = $self->_extract_scan_file($file) );
  return undef;
}

sub _build__scanned_data {
  my ($self) = shift;
  my (%data);

  for my $file ( @{ $self->_scan_list } ) {
    $self->logstate("$file");
    next unless my $found = $self->_scan_file($file);

    # TODO : Smells like WTF
    # Hash Merge?
    for my $class ( keys %{$found} ) {
      $data{$class} = $found->{$class};
    }
  }
  return \%data;
}

sub _build__extra_files_data {
  my ($self) = shift;
  return {} unless $self->has_extra_files;

  # Load Configuration Here.
  my $conf  = $self->_extra_files_reader->read_file( $self->extra_files );
  my $cconf = {};

  # Filter/Validate Config
  for my $class ( keys %{$conf} ) {
    $cconf->{$class} = {};
    Carp::croak( "No File defined for Module $class in " . $self->extra_files )
      unless exists $conf->{$class}->{'file'};
    $cconf->{$class}->{'file'} = $conf->{$class}->{'file'};
    next unless exists $conf->{$class}->{'version'};
    $cconf->{$class}->{'version'} = $conf->{$class}->{'version'};

  }
  return $cconf;
}

sub _build__provides {
  my ($self) = shift;

  my $scanned        = $self->_scanned_data();
  my $extrafilesdata = $self->_extra_files_data();

  # Override scanned with specified data
  for my $k ( keys %{$extrafilesdata} ) {
    my $mod = $extrafilesdata->{$k};
    $scanned->{$k} ||= {};
    $scanned->{$k}{'file'} = $mod->{'file'} if exists $mod->{'file'};
    $scanned->{$k}{'version'} = $mod->{'version'}
      if exists $mod->{'version'};
  }
  if ( $self->inherit_version ) {

    # Overwrite all scanned versions with zilla
    for my $k ( keys %{$scanned} ) {
      $scanned->{$k}->{'version'} = $self->zilla->version;
    }
  }
  elsif ( $self->inherit_missing ) {

    # Only Fill Gaps
    for my $k ( keys %{$scanned} ) {
      next if exists $scanned->{$k}->{'version'};
      $scanned->{$k}->{'version'} = $self->zilla->version;
    }
  }
  return $scanned;
}

sub metadata {
  my ($self) = @_;
  return { provides => $self->_provides };
}

#
# Logging Code, ignore, or disable. Your choice.
#
my $d = 0;
our $in;

sub logstate {
  use Data::Dumper;
  shift->log( " " x $d . "\e[31m| \e[33m" . $in . "\e[0m|" . Dumper( \@_ ) );
}

around qw( _build__scan_list _build__extra_files_reader _cd_scan_file
  _extract_scan_file _scan_file _build__scanned_data
  _build__extra_files_data _build__provides metadata

  ) => sub {
  my $orig   = shift;
  my $self   = shift;
  my (@call) = caller(2);
  use Data::Dumper;
  local $Data::Dumper::Indent = 0;
  local $Data::Dumper::Terse  = 1;
  local $Data::Dumper::Useqq  = 1;
  $call[3] =~ s/Dist::Zilla::Plugin:://g;
  $self->log(
    " " x $d . "\e[32m>> \e[33m" . $call[3] . "\e[0m |  " . Dumper( \@_ ) );
  $d++;
  local $in = $call[3];

  if (wantarray) {
    my @result = $self->$orig(@_);
    $d--;
    $self->log( " " x $d
        . "\e[32m<< \e[33m"
        . $call[3]
        . "\e[0m | "
        . Dumper( \@result ) );
    return @result;
  }
  else {
    my $result = $self->$orig(@_);
    $d--;
    $self->log( " " x $d
        . "\e[32m<< \e[33m"
        . $call[3]
        . "\e[0m | "
        . Dumper( \$result ) );
    return $result;
  }
  };

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
__PACKAGE__->meta->make_immutable();
1;
