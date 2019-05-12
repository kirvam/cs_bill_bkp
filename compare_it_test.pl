#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $file1 = shift;
my $file2 = shift;
my %hash;

my @ex_screen_heading = ( 'Name','State','CPUs','Memory Size (MB)','Guest OS','Status','Provisioned Space','Used Space','Host','DNS Name','Managed By','IP Address' );
my @cli_report_heading = ( '#','VM Name','numCPU','memoryMB','Provisioned','Used','Remaining' );
my @bill_2018 = ( 'Name','CPU Count','Memory Size \(MB\)','BLANK','T1_storage','T2_storage','T3_storage','T4_storage','Provisioned');

my($href,$aref) = ident_cols(@ex_screen_heading);
#print Dumper \$href;
my($href,$aref) = ident_cols(@cli_report_heading);
#print Dumper \$href;

my($gb,$tb) = conv_(8650271528008,'B');
print "\n$gb\n$tb\n\n";

my($gb,$tb) = conv_($gb,'G');
print "\n$gb\n$tb\n\n";

my($gb,$tb) = conv_(4237,'G');
print "\n$gb\n$tb\n\n";

exit;
my($first_file_href_cli,$href_flat_cli) = read_file_($file1,$href,2019);
print Dumper \$first_file_href_cli;
print Dumper \$href_flat_cli;

my($col_href,$col_aref) = ident_cols(@bill_2018);
print Dumper \$col_href;
#
# $href is col href
# Global %hash
# $href_cli - hash of first file

my($second_file_href_cli,$second_href_flat_cli) = read_file_($file2,$col_href,2018);
print Dumper \$second_file_href_cli;
print Dumper \$second_href_flat_cli;

my($href,$report) = compare_hash_($first_file_href_cli,$second_file_href_cli,'2019_2018_analysis.csv');
exit;
#my($href_cli,$href_flat_cli,$file) = compare_against_first($file2,$col_href,$first_file_href_cli,\%hash,'NA');


exit;

##############################################################

# sub
sub conv_{
my($value,$stype) = @_;
my $gb;
my $tb;
my %table = (
           'B' => sub { my ($val) = @_;
                        $val = ( $val/1073741824 );
                        return $val;
                      },
           'G' => sub { my ($val) = @_;
                        $val = ( $val/1000 );
                        return $val;
                      }
          );
if ( $stype eq 'B' ) {
      $gb = $table{$stype}->($value);
      $tb = conv_($gb,'G');
       } else {
        $gb = $value;
        $tb = $table{$stype}->($value);
     };

#sprintf("%.2f", 1.555);  # 1.56
#sprintf("%.2f", 1.554);  # 1.55
$gb = sprintf("%.2f", $gb); 
$tb = sprintf("%.2f", $tb);

   return($gb,$tb);
};

sub compare_hash_ {
my($first_file_href_cli,$second_file_href_cli,$report) = @_;
my %hash;
my $fh;
open ( $fh, ">", $report ) || die "Flaming death on open of $report: $!\n";

foreach my $name ( sort keys %{ $first_file_href_cli } ){
      print "key: $name\n";
       if ( exists $second_file_href_cli->{$name} ) {
          my @array = split(/,/,$second_file_href_cli->{$name});
          #my ($provgb,$usedtb) = conv_($second_file_href_cli->{$name}[1],'B');
          #my ($usedgb,$usedtb) conv_($second_file_href_cli->{$name}[2],'B');
          print $fh "$name,$second_file_href_cli->{$name}[1],$second_file_href_cli->{$name}[2],$first_file_href_cli->{$name}[1],$first_file_href_cli->{$name}[2]\n";
          #print $fh "$name,$provgb,$usedgb,$first_file_href_cli->{$name}[1],$first_file_href_cli->{$name}[2]\n";

       } else {
               print $fh "$name,$first_file_href_cli->{$name}[1],$first_file_href_cli->{$name}[2]\n";
      };
  };
};

sub ident_cols {
my(@headings) = @_;
my %hash = ();
my @array;
foreach my $ii ( 0 .. $#headings ){
   # print "$headings[$ii]\n";
   ### ,   VM Name,
    if ( $headings[$ii] =~ m/^
                                     (
                                (Name)|
                         \s?..\s(Name)|
                         (Provisioned)|
                                 (Used)
                              )
                              /xgi ) { 
       $hash{$1} = $ii;
       push @array, $ii;
     };
 };
print "\n";
 return(\%hash,\@array);
};

sub read_file_ {
my($file,$col_href,$loc) = @_;
my %hash;
my %flat_hash;
my $diskp = 0;
my $diskc = 0;
my $name;
my $prov;
my $consum;
my $ii;
open ( FH, "<", $file ) || die "Flaming death on open of $file: $!\n";
while (<FH>){
    my $line = $_;
    chomp $line;
    $line =~ s/"//g;
    if( $line =~ m/^#.*/g ||  $line =~ m/Name/g ) { print "Skipping header.\n"; next; };
    $ii++;
    my @line = split(/, */,$line);
    my $name_col = $col_href->{'VM Name'} || $col_href->{'Name'};
    #print "## $name_col\n";
    $name = $line[$name_col];
    my $prov_col = $col_href->{Provisioned};
    #print "## $prov_col\n";
    $prov = $line[$prov_col];
    if ( ! exists $col_href->{Used} ) { 
               $consum = int( $prov * .68 );           
         } else {
                my $consum_col = $col_href->{Used};
                $consum = $line[$consum_col];
        }
    #print "## $consum_col\n"; 
    #$consum = $line[$consum_col];
    print "$ii,^$name^, $prov, $consum, $loc\n";
     $hash{$name} = [ $name, $prov, $consum, $loc, $ii ];
     $flat_hash{$name} = $name.",".$prov.",".$consum.",".$loc;
    };
return(\%hash,\%flat_hash);
};
