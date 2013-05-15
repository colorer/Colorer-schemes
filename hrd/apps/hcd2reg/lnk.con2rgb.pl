#!perl 
#
# Change palette in w2k .lnk files.
# Written by Eugene Efremov.
#
# Warning: may be wrong.

use strict;
@ARGV < 2 or die "Use: lnk.con2rgb.pl link.lnk scheme.hcd \n";

my $LNK = shift;
my @cols;

# not while(<>): we need correct read xml...
my $hcd=join('',<>);
$hcd =~ s/<!--.+?-->//gs;
$hcd =~ s{<color (.+?)/>}
{
	my $t=$1;
	my $n=hex($2) if $t=~m/con\s*=\s*(['"])#([A-F\d])\1/s; 
	my @v=($2,$3,$4,0) if $t=~m/rgb\s*=\s*(['"])#(\w{2})(\w{2})(\w{2})\1/s;
	@cols[$n]=join('',map{chr(hex($_))}@v);
}ges;

my $psk = join('',@cols);


open LNK, "+< $LNK" or die "$LNK: $!\n";
binmode LNK;		#protect from 10 13
seek LNK, -68, 2;
syswrite LNK, $psk, 64;
close LNK;

print "$LNK updated\n";

__END__

#test:
my @lst=unpack('(C4)16',$psk);
print "\nPack: @lst\n";
