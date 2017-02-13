
#!/usr/bin/perl
#Function: Read swap part from swap file, edit certian coverpoint for ral_dxus.sv
#created by Kaidi Zhou @ 6/16/2014

use Getopt::Long;

my $datestring = localtime();
print "Start running SN3_OP_duplicate_check.pl at: $datestring\n";

#open source file and List file with command line
my $input_file;
my $help;
GetOptions ("input=s" => \$input_file, # RalAccessWrapper_Template
	          "h" => \$help) # help
or print("Error in command line arguments\n");

if($help == 1)
{
  print "\SN3_Full_Cov_Gen.pl -input=SN3_OP.sv\n";
  print "\nThis script will generate SN3_Full_Cov.sv\n";
}
if($input_file eq '')
{
    print "[ERROR]:SN3_Full_Cov_Gen.pl :Please define input file\n";
}

#other parameter
my $line_s;
my $line_o;
my $i = 0;

open my $input, $input_file or print "[ERROR]:SN3_Full_Cov_Gen.pl :Could not open $input_file: $!\n"; #read in the source file
open (my $output, '> DAX_SN3_OP_duplicate.txt');

print $output "cov_dax_diag_quality : coverpoint {covWi.ccb.opcode, covWi.ccb.input_format[0], covWi.ccb.input_size_type[0], covWi.ccb.input_compression_OZIP[0], covWi.ccb.input_compression_RLE[0], covWi.ccb.decimation_type[0], covWi.ccb.decimation_type[1], covWi.ccb.hash_enable, covWi.ccb.output_format[0], covWi.ccb.partitionOutputFormat, covWi.ccb.input_format[1], covWi.ccb.input_size_type[1], covWi.ccb.input_compression_RLE[1] } {\n\n";

#print $output_2_29 "Dax_2_29_cov : coverpoint {covWi.ccb.opcode, covWi.ccb.input_format[0], covWi.ccb.input_size_type[0], covWi.ccb.input_compression_OZIP[0], covWi.ccb.input_compression_RLE[0], covWi.ccb.decimation_type[0], covWi.ccb.decimation_type[1], covWi.ccb.hash_enable, covWi.ccb.output_format[0], covWi.ccb.input_format[1], covWi.ccb.input_size_type[1], covWi.ccb.input_compression_RLE[1] } {\n\n";

# This while scan RalAccessWrapper_Template to generate RalAccessWrapper.sv

#BIT_CONJUNCT, VALID, IPFMT_FWBYT, VALID, IPSIZE_ANY, VALID, OZIP_ENABLE, VALID, RLE_DISABLE, INVALID, SinA_KEY_DECM.first(), INVALID, SinA_VAL_DECM.first(), VALID, HASH_DISABLE, VALID, OPFMT_PACKED_BYT, INVALID, Sin_PARTITION_OPFMT.first(), VALID, IPFMT_FWBYT, VALID, IPSIZE_ANY, VALID, RLE_DISABLE
#
#wildcard bins 
#{{BIT_CONJUNCT, IPFMT_FWBYT, IPSIZE_ANY, OZIP_ENABLE, RLE_DISABLE, 3'b???, 3'b???, HASH_DISABLE, OPFMT_PACKED_BYT, 3'b???, IPFMT_FWBYT, IPSIZE_ANY, RLE_DISABLE}};
#my %duplicate_hash = ( 'xyz' => 'abc');
my %duplicate_hash;
my $fail;

while ($line_o = <$input>) {                                      #scan the whole table file
  if($line_o =~ m/({.*})/) {
    my($check) = $1;
    my $check_string = "$check";

    if (exists  $duplicate_hash{$check_string}) {
      print $output "entry $duplicate_hash{$check_string} duplicate with : $line_o\n";
      $fail = 1;
    }
    else
    {
      $duplicate_hash{$check_string} = $i;
    }

#    print "$check_string  $i\n";    
    $i++;
  }
	else
	{
	  if(eof)
	  {
		#print "SN3_Full_Cov.sv finish\n\n";
	  }
	}
}

if ($fail == 1) {
  die "Dpulicated entry detect for SN3_OP.sv";
}

print "SN3_OP_duplicate_check.pl finish\n";
close $output;

$datestring = localtime();
print "Stop running SN3_OP_duplicate_check.pl at: $datestring\n";

