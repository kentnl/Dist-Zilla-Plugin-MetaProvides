use strict;
use warnings;
package # NO PAUSE PLX
  TZil;

use Try::Tiny;
use Dist::Zilla::Tester qw( Builder );
use Params::Util qw(_HASH0);

use Sub::Exporter -setup => {
  exports => [
    test_config =>
    simple_ini  => \'_simple_ini',
  ],
  groups => [ default => [ qw( -all ) ] ]
};

sub test_config {
  my ( $conf ) = shift;
  my $args = [];
  if ( $conf->{dist_root} ) {
    $args->[0] = { dist_root => $conf->{dist_root} };
  }
  if ( $conf->{ini} ){
    $args->[1] ||= {};
    $args->[1]->{add_files} ||= {};
    $args->[1]->{add_files}->{'source/dist.ini'} = _simple_ini()->( @{ $conf->{ini} } );
  }
  my $build_error = undef;
  my $instance;
  try {
    $instance = Builder->from_config( @$args );

    if ( $conf->{build} ){
      $instance->build();
    }
  } catch {
    $build_error = $_;
  };

  if ( $conf->{post_build_callback} ) {
    $conf->{post_build_callback}->({
      error => $build_error,
      instance => $instance,
    });
  }

  if ( $conf->{find_plugin} ){
    my $plugin = $instance->plugin_named( $conf->{find_plugin} );
    if ( $conf->{callback} ){
      my $error = undef;
      my $method = $conf->{callback}->{method};
      my $args   = $conf->{callback}->{args};
      my $call   = $conf->{callback}->{code};
      my $response;
      try {
        $response = $instance->$method( @$args );
      } catch {
        $error = $_;
      };
      return $call->({
        error => $error,
        response => $response,
        instance => $instance,
      });
    } else {
      return $plugin;
    }
  }
}

sub _build_ini_builder {
  my ($starting_core) = @_;
  $starting_core ||= {};

  sub {
    my (@arg) = @_;
    my $new_core = _HASH0($arg[0]) ? shift(@arg) : {};

    my $core_config = { %$starting_core, %$new_core };

    my $config = '';

    for my $key (keys %$core_config) {
      my @values = ref $core_config->{ $key }
                 ? @{ $core_config->{ $key } }
                 : $core_config->{ $key };

      $config .= "$key = $_\n" for grep {defined} @values;
    }

    $config .= "\n" if length $config;

    for my $line (@arg) {
      my @plugin = ref $line ? @$line : ($line, {});
      my $moniker = shift @plugin;
      my $name    = _HASH0($plugin[0]) ? undef : shift @plugin;
      my $payload = shift(@plugin) || {};

      die "TOO MANY ARGS TO PLUGIN GAHLGHALAGH" if @plugin;

      $config .= '[' . $moniker;
      $config .= ' / ' . $name if defined $name;
      $config .= "]\n";

      for my $key (keys %$payload) {
        my @values = ref $payload->{ $key }
                   ? @{ $payload->{ $key } }
                   : $payload->{ $key };

        $config .= "$key = $_\n" for @values;
      }

      $config .= "\n";
    }

    return $config;
  }
}

sub _dist_ini {
  _build_ini_builder;
}

sub _simple_ini {
  _build_ini_builder({
    name     => 'DZT-Sample',
    abstract => 'Sample DZ Dist',
    version  => '0.001',
    author   => 'E. Xavier Ample <example@example.org>',
    license  => 'Perl_5',
    copyright_holder => 'E. Xavier Ample',
  });
}

1;