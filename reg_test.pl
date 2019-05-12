
use strict;
use warnings;

my $file = shift;

open(my $fh,"<",$file) || die "Flaming death: $!\n";

while(<$fh>){
my $line = $_;
chomp($line);
my @array = split(/-/,$line);
my $string = $array[0];
print "printing \$string: $string\n";
eval_string($string);

};
#close $fh;

# SUBS
#
########
sub eval_string {
# sub to eval uate string for fist "word" separated by "-" dash..
my($string) = @_;
my $name;
chomp($string);
if($string =~ m/^(\w{3,5})-*/igx){
    $name = $1;
    print "\t\$1: $name\n";
  } else {
    print "No match.\n";
     next;
  }

return($name);
}; 
