use strict;
use warnings;

#
my %HoA = (
            flintstones        => [ "fred", "barney" ],
            jetsons            => [ "george", "jane", "elroy" ],
            simpsons           => [ "homer", "marge", "bart" ],
          );


my $ref =\%HoA;

print "\n--Start---\n";

print "Print HoA via hash (straight).\n";
print_hash(%HoA);

print "\n\n";

print "Print HoA via ref.\n";
print_hash_ref($ref);
# OR
# print_hash_ref(\%HoA);

print "---End---\n\n";

### SUBS
sub print_hash {
# sub to print HoA
my(%hash) = @_;
print "---< Start print_hash Sub >-----\n";
foreach my $key ( sort ( keys %hash ) ){
          print "$key:\n";
           foreach my $ii ( 0 .. $#{ $hash{$key}} ){
             print "\t$ii: $hash{$key}[$ii]\n";
   }
  };                                     
print "---< End print_hash Sub >-----\n";
};

sub print_hash_ref {
# sub to print HoA
my($ref) = @_;
print "---< Start print_hash_ref Sub >-----\n";
foreach my $key ( sort ( keys %$ref ) ){
      ### print "$key | ${$ref}{$key}\n";
          print "$key:\n";
           foreach my $ii ( 0 .. $#{@{$ref}{$key}} ){
             print "\t$ii: ${$ref}{$key}[$ii]\n";
      ### print $key , ",", ${$ref}{$key}, "\n";
      ### print ${$array_ref}{$key}, ",", $key, "\n";
   }
  };                                     
print "---< End print_hash_ref Sub >-----\n";
};
