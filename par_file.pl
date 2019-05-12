
use strict;
use warnings;
use Data::Dumper;

# config
my $fields = 18; #there must be this many fields;

my $file = shift;
my %HoA;
my @heading = ( 'Name',
                'State',
                'CPU Count',
                'Memory Size (MB)',
                'Guest OS',
                'Status',
                'Provisioned Space',
                'Used Space',
                'Host',
                'Owner',
                'T1_VM',
                'T1_storage',
                'T2_storage',
                'T3_storage',
                'T4_storage',
                'RPO_hrs',
                'RTO_hrs',
                'VM_cost',
                'Storage_cost',
                'Total_VM_cost'
                );


print "--<start>--\n";

print_fields($fields);
my ($file,$headings) = parse_file($file);
make_array_and_count($headings);
my $refHoA;
$refHoA = make_fields($file,$headings,\%HoA);

print "Dumper for \$refHoA\n";
print Dumper \$refHoA;
print_hash_ref($refHoA);

my $name = "SPX1";
my $name = "SPX4";
iterate_array($name,$refHoA,@heading);

print "--<end>--\n";



# SUBS
#
###
sub iterate_array {
# sub to create tabs for each tag/key in HoA
my($name_for_sheet,$ref,@heading) = @_;
use Excel::Writer::XLSX;
$name_for_sheet = $name_for_sheet."\.xlsx";
my $workbook = Excel::Writer::XLSX->new( $name_for_sheet );
print "---< Start iterate_array >---\n";
my $totals = "TOTALS";
my $worksheettotal = $workbook->add_worksheet( $totals );
  my $total_tab_start = 4;
  my $trow = 3;
  my $new_c;
 my $formath = $workbook->add_format();
      $formath->set_bold(1);
      $formath->set_align('left');
      $formath->set_bg_color('green');
      $formath->set_color('white');
      $formath->set_font('Tahoma');
      $formath->set_size('10');
         foreach my $ii ( 0 .. $#heading ){
           print "write line: 2, $ii, $heading[$ii]\n";
             $worksheettotal->write( 2, $ii, $heading[$ii], $formath  );
         };

foreach my $key ( sort ( keys %$ref ) ){
  print "$key:\n";
  if($key =~ m/Owner/gi){ print "found Owner: $key.\n"; next; };
  if($key =~ m/eag/gi){ print "found Owner: $key.\n"; next; };
  if($key =~ m/vshield/gi){ print "found Owner: $key.\n"; next; };
  
# Add a worksheet
   my $worksheet = $workbook->add_worksheet( $key );
   my $format = $workbook->add_format();
      $format->set_bold(1);
      $format->set_align('left');
      $format->set_bg_color('green');
      $format->set_color('white');
      $format->set_font('Tahoma');
      $format->set_size('10');
         print "write line: 0, 0, $key\n";
         $worksheet->write( 0, 0, $key, $format );
            foreach my $ii ( 0 .. $#heading ){
              print "write line: 2, $ii, $heading[$ii]\n";
               $worksheet->write( 2, $ii, $heading[$ii], $format  );
                  };
# set row to start on row 2 to allow for header..
      my $col = 0; my $row = 3;
      #my $total_tab_start = $row; $total_tab_start++;
      my $start_col = $#heading; 
      my $start_row = $row+1;
      my $sum_start = "S".$start_row;  print "\$start_col: $start_col\n";   ###########  here...
      
       my $format1 = $workbook->add_format();
          $format1->set_bold(0);
          $format1->set_bg_color();
          $format1->set_color();
          $format1->set_font( 'Tahoma' );
          $format1->set_size( '10' );

       foreach my $ii ( 0 .. $#{@{$ref}{$key}} ){
          my @array = @{ ${$ref}{$key}[$ii] } ;
             foreach my $jj ( 0 .. $#array ){
               #$col = $ii+2; # controls start of column
                 $col = $jj;
                  print "write line: $row, $col, $array[$jj]\n";
                    $worksheet->write( $row, $col, $array[$jj], $format1 );
                  print "write totals line: $trow, $col, $array[$jj]\n";
                    $worksheettotal->write( $trow, $col, $array[$jj], $format1 );
                    
                    print "\t$ii,$jj: $array[$jj]\n";
              }
                 ### sets col for next and final row which totals VM and Storage Costs..  It increments col by 1..
                 my $new_c = $col; $new_c++;
                 ### new_row is copy of row
                 my $new_row = $row; $new_row++;  ### new_row, need to increment because the cell notation is +1 than the row notation.. 
                 my $new_trow = $trow; $new_trow++;  ### same here, the cell notation is +1, so if sheet row is 3 then cell in 
                                                     ### excel is 4..  excel starts counting at 1, perl at 0..
                                                     ###
                 my $sum_field = "=sum("."R".$new_row.":"."S".$new_row.")";  print $sum_field, "\n";
                 my $sum_total_field = "=sum("."R".$new_trow.":"."S".$new_trow.")";  print $sum_total_field, "\n";
             
                 print "write sum cell: $row, $new_c, $sum_field \n";
                   $worksheet->write( $row, $new_c, $sum_field, $format1 );
                 print "write totals sum cell: $trow, $new_c, $sum_total_field\n";
                   $worksheettotal->write( $trow, $new_c, $sum_total_field, $format1 );
            $row++;
            $trow++;
       }
### This writes at end of the list of servers on each Tab.. 
 ### col 18, S totals for Storage Costs
          my $final_row = $row;
           my $place_row = $final_row+1;
          my $final_col = $start_col;
          my $sum_end = "S".$final_row;
          print "\$sum_end: $sum_end\n";
          my $sum = "\=sum\($sum_start:$sum_end\)";
           print "\$sum: $sum\n";
          print "write line: $row, $final_col, $sum\n";
  ###  Abandoned..
  ###      $worksheet->write( $row, $col, $array[$jj], $format1 );
  ###      $worksheet->write( $row, $col, $sum, $format1 );

  ### col 17, R totals for VM Costs...
          my $final_col = $start_col-1;
          my $sum_end = "R".$final_row;
          my $sum_start = "R".$start_row;
          my $vsum = "\=sum\($sum_start:$sum_end\)";
           print "\$sum: $sum\n";
          my $vm_col = $final_col;
          print "write line: $row, $vm_col, $vsum\n";
  ### Abandoned..
  ###      $worksheet->write( $row, $vm_col, $vsum, $format1 );
  ###    
  ### TOTALS Label
          $sum=~s/\=//g;
          $vsum=~s/\=//g;
          my $tsum = "\=\($sum \+ $vsum\)";
          my $t_col = $vm_col;
          $row = $row+2;
          print "write line: $row, $t_col, 'Total'\n";
  ###      $worksheet->write( $row, $t_col, 'Total', $format1 );
          my $t_col = $vm_col+1;
          print "write line: $row, $t_col, $tsum\n";
  ###  Totals SUM
          $worksheet->write( $row, $t_col, $tsum, $format1 );

  ###     Sets new column for ???
          $new_c = $col;
  ###
  ###     Here is wher to add the extra labels/products..
  ###
      };
        ### FOR TOTALS TAB
                 #my $new_c = $col; $new_c++;
                 #my $new_row = $row; $new_row++;
                 #my $new_trow = $trow; $new_trow++;
                 my $new_trow = $trow;  
               #$new_trow--;
                 #my $sum_field = "=sum("."R".$new_row.":"."S".$new_row.")";  print $sum_field, "\n";
                 my $sum_total_field = "=sum("."T".$total_tab_start.":"."T".$new_trow.")";  print $sum_total_field, "\n";
                 $new_c++;
                 print "write final totals sum cell: $trow, $new_c, $sum_total_field\n";
                 #$worksheettotal->write( $trow, $new_c, $sum_total_field, $format1 );
                 $worksheettotal->write( $trow, $new_c, $sum_total_field );

    
print "---< End iterate_array >-----\n";
};

###
sub print_hash_ref {
# sub to print HoA
my($ref) = @_;
print "\n\n---< Start print_hash_ref Sub >-----\n";
 foreach my $key ( sort ( keys %$ref ) ){
      print "$key:\n";
       foreach my $ii ( 0 .. $#{@{$ref}{$key} } ){
             my @array = @{ ${$ref}{$key}[$ii] } ;    
            #foreach my $jj ( 0 .. $#{ @{$ref}{$key}[$ii] } ){
                 if($#array < 18){ print "LESS than 18\n";};
                foreach my $jj ( 0 .. $#array ){
                     print "\t$ii,$jj: $array[$jj]\n";
                      };
               ### print "\t$ii: ${$ref}{$key}[$ii][$jj]\n";
       };
 };
print "---< End print_hash_ref Sub >-----\n";
};

sub print_fields {
my($fields) = @_;
print "There needs to be: $fields.\n";
};

sub make_array_and_count{
print "\n---make_array_and_count---\n";
# $array should be split by comma,",".
my($headings) = @_;
my @headings = split(/,/,$headings);
print "\nNumber of Headings:\n";
for my $ii ( 0 .. $#headings ){
     print "$headings[$ii] [$ii ++ 1]\n";
 }
};

sub make_fields{
print "\n--make-fields---\n";
my($file,$headings,$refHoA) = @_;
my @headings = split(/,/,$headings);
open ( my $fh, "<", $file ) || die "Flaming death on open: $!";
while (<$fh>){
my $line = $_;
chomp($line);
my @line = split(/,/,$line);
my @array;
print "\n";
for my $ii ( 0 .. $#headings ){
     #print "\$ii: $ii\n";
     if( ! $line[$ii] ){ #print "Found NO VAL.\n"; 
        $line[$ii] = "0";
    } 
###
     my $val = $line [$ii];
     $val =~ s/\r//;
###    
###    push @array, $line [$ii];
       push @array, $val;
     #print "$headings[$ii] => $line[$ii]\n";
  }
    if( $array[9] eq "0" ){ print "--FOUND NO OWNER, $array[0]\n";
         if ( $array[0] =~ m/^(\w{3,})\-/g ){
              $array[9] = $1;
               print "--$1\n";
             } else {
                 print "--CST\n";      
                 $array[9] = "CST";
        }
  }
     for my $ii ( 0 .. $#array){
         print "$headings[$ii]=>$array[$ii]\n";
    }
   my $owner = $array[9];
   if(${$refHoA}{$owner}){
          push @{ $refHoA->{$owner} }, [ @array ];
      }  
    else {
       @{ $refHoA->{$owner} } = [ @array ];
       }
#     print Dumper \$refHoA;
 }
close $fh;
return ($refHoA);
};

sub parse_file {
my($file) = @_;
my $ii = 0;
my $jj = 0;
my $headings;
open ( my $fh, "<", $file ) || die "Flaming death on open: $!";
while (<$fh>){
$ii++;
my $line = $_;
chomp($line);
if ($ii eq 1){ $headings = $line;
    print $headings,"\n";
    };
my @array = split(/,/,$line);
#print Dumper \@array;
my $count = $#array;
print "count: $count\n";
$jj++;
 }
close $fh;
print "Here are the headings:\n$headings\n";
print "Total lines: $jj\n";
return($file,$headings);
};
