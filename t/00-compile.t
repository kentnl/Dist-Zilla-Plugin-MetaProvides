use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::Compile 2.032

use Test::More  tests => 4 + ($ENV{AUTHOR_TESTING} ? 1 : 0);



my @module_files = (
    'Dist/Zilla/MetaProvides/ProvideRecord.pm',
    'Dist/Zilla/MetaProvides/Types.pm',
    'Dist/Zilla/Plugin/MetaProvides.pm',
    'Dist/Zilla/Role/MetaProvider/Provider.pm'
);



# no fake home requested

my @warnings;
for my $lib (@module_files)
{
    my ($stdout, $stderr, $exit_code) = _capture(
        sub {
            system($^X, '-Mblib', '-e', "require q[$lib]");
        }
    );

    is($exit_code >> 8, 0, "$lib loaded ok");

    if (my @_warnings = split /\n/, $stderr)
    {
        warn @_warnings;
        push @warnings, @_warnings;
    }
}



is(scalar(@warnings), 0, 'no warnings found') if $ENV{AUTHOR_TESTING};



#--------------------------------------------------------------------------#
# Capture::Tinier, courtesy of David Golden (see L<Capture::Tiny>)
#--------------------------------------------------------------------------#

use IO::Handle;
use Carp;
use File::Temp;

my $IS_WIN32 = $^O eq 'MSWin32';

sub _open {
    open $_[0], $_[1] or Carp::confess "Error from open(" . join( q{, }, @_ ) . "): $!";
}

sub _close {
    close $_[0] or Carp::confess "Error from close(" . join( q{, }, @_ ) . "): $!";
}

sub _copy_std {
    my %handles;
    for my $h (qw/stdout stderr stdin/) {
        next if $h eq 'stdin' && !$IS_WIN32; # WIN32 hangs on tee without STDIN copied
        my $redir = $h eq 'stdin' ? "<&" : ">&";
        _open $handles{$h} = IO::Handle->new(), $redir . uc($h); # ">&STDOUT" or "<&STDIN"
    }
    return \%handles;
}

# In some cases we open all (prior to forking) and in others we only open
# the output handles (setting up redirection)
sub _open_std {
    my ($handles) = @_;
    _open \*STDIN,  "<&" . fileno $handles->{stdin}  if defined $handles->{stdin};
    _open \*STDOUT, ">&" . fileno $handles->{stdout} if defined $handles->{stdout};
    _open \*STDERR, ">&" . fileno $handles->{stderr} if defined $handles->{stderr};
}

sub _slurp {
    my ( $name, $stash ) = @_;
    my $fh = $stash->{new}{$name};
    seek( $fh, 0, 0 ) or die "Couldn't seek on capture handle for $name\n";
    my $text = do { local $/; scalar readline $fh };
    return defined($text) ? $text : "";
}

sub _capture {
    my ($code) = @_;
    my $stash;
    $stash->{old} = _copy_std();
    $stash->{new} = { %{ $stash->{old} } }; # default to originals
    for (qw/stdout stderr/) {
        $stash->{new}{$_} = File::Temp->new;
    }
    _open_std( $stash->{new} );
    my ( $exit_code, $inner_error, $outer_error, @result );
    {
        local $@;
        eval { @result = $code->(); $inner_error = $@ };
        $exit_code   = $?;                  # save this for later
        $outer_error = $@;                  # save this for later
    }
    _open_std( $stash->{old} );
    _close($_) for values %{ $stash->{old} }; # don't leak fds
    my %got;
    for (qw/stdout stderr/) {
        $got{$_} = _slurp( $_, $stash );
    }
    $? = $exit_code;
    $@ = $inner_error if $inner_error;
    die $outer_error if $outer_error;
    return ( $got{stdout}, $got{stderr}, @result );
}
