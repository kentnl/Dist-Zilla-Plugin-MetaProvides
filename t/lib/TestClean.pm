package TestClean;
our $VERSION = '1.092000';


# $Id:$
my $CLASS = __PACKAGE__;
use base 'Test::Builder::Module';
@EXPORT = qw( is_clean );

sub pp {
    require Data::Dumper;
    local $Data::Dumper::Terse  = 1;
    local $Data::Dumper::Useqq  = 1;
    local $Data::Dumper::Indent = 0;
    return Data::Dumper::Dumper(shift);
}

sub is_clean($;$) {
    my $file = shift;
    my $msg  = shift;
    $msg ||= "Cleanlyness for $file";
    my $tb   = $CLASS->builder;
    my $fh;

    if ( not open $fh, '<', $file ) {
        my $o = $tb->ok( 0, $msg );
        $tb->diag("Loading $file Failed");
        return $o;
    }
    while ( my $line = <$fh> ) {

        # Tailing Whitespace is pesky
        if ( $line =~ qr/\h$/m ) {
            my $o = $tb->ok( 0, $msg );
            $tb->diag( "\n\n\\h found on end of line $. in $file\n" . pp($line) . "\n" );
            return $o;
        }

        # Tabs are teh satan.
        if ( $line =~ qr/\t/m ) {
            my $o = $tb->ok( 0, $msg );
            $tb->diag( "\\t found in line $. in $file\n" . pp($line) . "\n" );
            return $o;
        }

        # Perltidyness in teh comments
        if ( $line =~ qr/[)][{]/ ) {
            my $o = $tb->ok( 0, $msg );
            $tb->diag( ')' . "{ found in line $. in $file\n" . pp($line) . "\n" );
            return $o;
        }
    }
    close $fh;
    return $tb->ok( 1, $msg );
}

1;
