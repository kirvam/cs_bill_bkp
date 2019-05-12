use strict;
use warnings;
use Data::Dumper;


my($cost,$pretty)= gen_cost(8,2,808);


print "COST: $cost\nPRETTY: $pretty\n\n";

sub gen_cost {
my($mem,$cpu,$prov) = @_;
# (1482.5+100*($mem - 1)*1.009^($mem - 1)+300*($cpu - 1)+($prov * 3.18))
 my $cost = (1482.5+100*($mem - 1)*1.009**($mem - 1)+300*($cpu - 1)+($prov * 3.18)) ;
 my $pretty = sprintf("%.2f", $cost);
 return($cost,$pretty);
};

