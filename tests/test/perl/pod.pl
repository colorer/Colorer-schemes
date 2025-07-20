my $fh = shift;

 # adsfasdfas
 # multiline value: name = <<TERM
 # ....
 # ....
 #
 # TERM

my( $n, $term ) = ( $1, $2 );
my $ok;
my $v = '';
while( $line = <$fh> )
{
    if( $line =~ /^$term\s*$/ )
    {
        $ok = 1;
        last;
    }

    $v .= $line;
}
