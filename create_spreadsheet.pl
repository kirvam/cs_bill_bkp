use strict;
use warnings;
use Data::Dumper;

my @data = qw( cat dog owl pig cow);
my %HoA = (
            flintstones        => [ "fred", "barney" ],
            jetsons            => [ "george", "jane", "elroy" ],
            simpsons           => [ "homer", "marge", "bart" ],
          );

my %HoA = (
'ADS' => [
                       [
                         'ENT-DCVSMS02',
                         'Powered On',
                         '2',
                         '8192',
                         'Microsoft Windows Server 2016 (64-bit)',
                         'Normal',
                         '88.13  GB',
                         '43.33  GB',
                         'eagpesx44.ea.dii.state.vt.us',
                         'ADS',
                         'FALSE',
                         '0',
                         '80',
                         '0',
                         '0',
                         '24',
                         '1344',
                         '2527.81',
                         '254.4'
                       ],
                       [
                         'ENT-DCVSMS03',
                         'Powered On',
                         '2',
                         '8192',
                         'Microsoft Windows Server 2016 (64-bit)',
                         'Normal',
                         '88.13  GB',
                         '40.76  GB',
                         'eagpesx38.ea.dii.state.vt.us',
                         'ADS',
                         'FALSE',
                         '0',
                         '80',
                         '0',
                         '0',
                         '24',
                         '1344',
                         '2527.81',
                         '254.4'
                       ],
                       [
                         'ENT-DCVSMS04',
                         'Powered On',
                         '2',
                         '8192',
                         'Microsoft Windows Server 2016 (64-bit)',
                         'Normal',
                         '88.13  GB',
                         '41.28  GB',
                         'eagpesx31.ea.dii.state.vt.us',
                         'ADS',
                         'FALSE',
                         '0',
                         '80',
                         '0',
                         '0',
                         '24',
                         '1344',
                         '2527.81',
                         '254.4'
                       ]
                     ],
            'EAG' => [
                       [
                         'ASR-CENTOS7-00',
                         'Powered On',
                         '2',
                         '4096',
                         'CentOS 4/5/6/7 (64-bit)',
                         'Normal',
                         '54.13  GB',
                         '54.13  GB',
                         'eagpesx39.ea.dii.state.vt.us',
                         'EAG',
                         '0',
                         '0',
                         '50',
                         '0',
                         '0',
                         '24',
                         '1344',
                         '2090.67',
                         '159'
                       ],
                       [
                         'AzureMigrate',
                         'Powered Off',
                         '4',
                         '8192',
                         'Microsoft Windows Server 2012 (64-bit)',
                         'Normal',
                         '88.33  GB',
                         '21.29  GB',
                         'eagpesx56.ea.dii.state.vt.us',
                         'EAG',
                         '0',
                         '0',
                         '80',
                         '0',
                         '0',
                         '0',
                         '0',
                         '3127.81',
                         '254.4'
                       ],
                    ],
);

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
                'Storage_cost'
                );

print Dumper \%HoA;
print Dumper \@heading;

#exit;


my $ref = \%HoA;

my $name = "SPS";

create_spreadsheet($name,@data);

my $name = "SPX";
iterate_array($name,$ref);

sub iterate_array {
# sub to create tabs for each tag/key in HoA
my($name_for_sheet,$ref) = @_;
use Excel::Writer::XLSX;
$name_for_sheet = $name_for_sheet."\.xlsx";
my $workbook = Excel::Writer::XLSX->new( $name_for_sheet );
print "---< Start iterate_array >---\n";
foreach my $key ( sort ( keys %$ref ) ){
  print "$key:\n";
# Add a worksheet
   my $worksheet = $workbook->add_worksheet( $key );
   my $format = $workbook->add_format();
      #$format->set_bold(0);
      #$format->set_bg_color();
      #$format->set_color();
      #$format->set_font('Tahoma');
      #$format->set_size('10');
      ###
         $format->set_bold(1);
         $format->set_align( 'left' );
         $format->set_bg_color('green');
         $format->set_color('white');
         $format->set_font('Tahoma');
         $format->set_size('10');
      ###
      print "write line: 0, 0, $key\n";
      $worksheet->write( 0, 0, $key, $format );
     foreach my $ii ( 0 .. $#heading ){
       ###
       ###
      print "write line: 2, $ii, $heading[$ii]\n";
      $worksheet->write( 2, $ii, $heading[$ii], $format );
      };
   # set row to start on row 2 to allow for header..
     my $col = 0; my $row = 3;
   ###
      $format->set_bold(0);
      $format->set_bg_color();
      $format->set_color();
      $format->set_font('Tahoma');
      $format->set_size('10');
   ###
      foreach my $ii ( 0 .. $#{@{$ref}{$key}} ){
           my @array = @{ ${$ref}{$key}[$ii] } ;
             foreach my $jj ( 0 .. $#array ){
                #$col = $ii+2; # controls start of column
                 $col = $jj;
                print "write line: $row, $col, $array[$jj]\n";
                $worksheet->write( $row, $col, $array[$jj], $format );    
               # 
                 print "\t$ii,$jj: $array[$jj]\n";
          } 
            $row++;
        }
  };
print "---< End iterate_array >-----\n";
};

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


sub create_spreadsheet {
# sub to create spreat sheet
#my(@data,$name_for_sheet) = @_;
my($name_for_sheet,@data) = @_;
use Excel::Writer::XLSX;

$name_for_sheet = $name_for_sheet."\.xlsx";
print "name_for_sheet: $name_for_sheet\n";
# Create a new Excel workbook
my $workbook = Excel::Writer::XLSX->new( $name_for_sheet );

# Add a worksheet
my  $worksheet = $workbook->add_worksheet();

#  Add and define a format
my  $format = $workbook->add_format();
  $format->set_bold();
  $format->set_color( 'red' );
  $format->set_align( 'center' );

# Write a formatted and unformatted string, row and column notation.
my $col;
my $row;
$col = $row = 0;
  $worksheet->write( $row, $col, 'Hi Excel!', $format );
  $worksheet->write( 1, $col, 'Hi Excel!' );

# Write a number and a formula using A1 notation
  $worksheet->write( 'A3', 1.2345 );
  $worksheet->write( 'A4', '=SIN(PI()/4)' );

};

