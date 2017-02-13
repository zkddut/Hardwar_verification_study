
#!/usr/bin/perl
#Function: Read swap part from swap file, edit certian coverpoint for ral_dxus.sv
#created by Kaidi Zhou @ 6/16/2014

use Getopt::Long;
#open source file and List file with command line
my $table_file;
my $const_file;
my $list_file;
my $help;
GetOptions ("input_table=s" => \$table_file, # DaxCcbConstTable_Templete
            "input_const=s" => \$const_file, # DaxCcbConstraints_Templete
	          "list=s" => \$list_file, # List.txt
	          "h" => \$help) # help
or print("Error in command line arguments\n");

if($help == 1)
{
  print "\nDaxCcbConstTable_Gen.pl -input_table=DaxCcbConstTable_Templete -input_const=DaxCcbConstraints_Templete -list=DaxCcbConstList.txt\n";
  print "\nThis script will generate DaxCcbConstTable.sv and DaxCcbConstraints.sv\n";
}
if($table_file eq '')
{
    print "[ERROR]:DaxCcbConstTable_Gen.pl :Please define input table file\n";
}
if($const_file eq '')
{
    print "[ERROR]:DaxCcbConstTable_Gen.pl :Please define input const file\n";
}
if($list_file eq '')
{
    print "[ERROR]:DaxCcbConstTable_Gen.pl :Please define list file\n";
}

#key word to in the swap part
my $GENERATE_NAME_BEG = "ZKD: GENERATE_NAME_BEG";
my $GENERATE_NAME_END = "ZKD: GENERATE_NAME_END";
my $GENERATE_FUNC_BEG = "ZKD: GENERATE_FUNC_BEG";
my $GENERATE_FUNC_END = "ZKD: GENERATE_FUNC_END";
my $GENERATE_PRINT_BEG = "ZKD: GENERATE_PRINT_BEG";
my $GENERATE_PRINT_END = "ZKD: GENERATE_PRINT_END";
my $GENERATE_CONST_BEG = "ZKD: GENERATE_CONSTRAINT_BEG";
my $GENERATE_CONST_END = "ZKD: GENERATE_CONSTRAINT_END";

my $enum_size = "string";
my $num_input = "`V_DAX_NUM_INPUT_LOGICALSTRMS";
my $num_track = "`V_DAX_NUM_TRACKS";
my $num_strm = "`V_DAX_NUM_STRMS_IN_LOGICALSTRM";
my $array_size = "`V_DXU_CONSTRAINT__MAX_SZ";

#other parameter
my $line_s;
my $line_o;

open my $table, $table_file or print "[ERROR]:DaxCcbConstTable_Gen.pl :Could not open $table_file: $!\n"; #read in the source file
open my $const, $const_file or print "[ERROR]:DaxCcbConstTable_Gen.pl :Could not open $const_file: $!\n"; #read in the source file
open my $list, $list_file or print "[ERROR]:DaxCcbConstTable_Gen.pl :Could not open $list_file: $!\n"; #read in the list file
open (my $table_output, '>DaxCcbConstTable.sv');
open (my $const_output, '>DaxCcbConstraints.sv');

#This while is used for scan List.txt. It will creat a hash table for all list name
while($line_s = <$list>){                          
  if(!($line_s =~ /^#/)) {                                              #For skip # comment
	  chomp($line_s);                                             
		$line_s =~ s/^\s+//;
		@cover_line = split(/ +/, $line_s);		             #split the line by space
    my $List_Func = $cover_line[0];                  #the first word will be the list Func
		my $List_Name = $cover_line[1];                  #the second word will be the list name
    my $List_Enum = $cover_line[2];
		print "$List_Func: $List_Name\n";
    push @list_func_a, $List_Func;
		push @list_name_a, $List_Name;                           #store name into array
    push @list_enum_a, $List_Enum;
  }
	else
	{
	  if(eof)
	  {
		#print "Scan update.txt finish\n\n";
	  }
	}
}

# This while scan DaxCcbConstTable_Templete to generate DaxCcbConstTable.sv
while ($line_o = <$table>) {                                      #scan the whole table file
  print $table_output $line_o;                                          #build new source file
  if($line_o =~ m/$GENERATE_NAME_BEG/)                          #find the line with $GENERATE_NAME_BEG
  {
    foreach my $i (0 .. $#list_name_a) {
      if($list_func_a[$i] eq "vl") {
        print $table_output "  int  $list_name_a[$i]_vl\[$array_size\];\n";
        print $table_output "  int  $list_name_a[$i]_wt\[$array_size\];\n\n";
      }
      if($list_func_a[$i] eq "enum") {
        print $table_output "  int  $list_name_a[$i]_wt\[$enum_size\];\n\n";
      }
      if($list_func_a[$i] eq "lo_hi") {
        print $table_output "  int  $list_name_a[$i]_lo\[$array_size\];\n";
        print $table_output "  int  $list_name_a[$i]_hi\[$array_size\];\n";
        print $table_output "  int  $list_name_a[$i]_wt\[$array_size\];\n\n";
      }
      if($list_func_a[$i] eq "vl_num_input") {
        print $table_output "  int  $list_name_a[$i]_vl\[$num_input\]\[$array_size\];\n";
        print $table_output "  int  $list_name_a[$i]_wt\[$num_input\]\[$array_size\];\n\n";
      }
      if($list_func_a[$i] eq "enum_num_input") {
        print $table_output "  int  $list_name_a[$i]_wt\[$num_input\]\[$enum_size\];\n\n";
      }
      if($list_func_a[$i] eq "enum_num_track") {
        print $table_output "  int  $list_name_a[$i]_wt\[$num_track\]\[$enum_size\];\n\n";
      }
      if($list_func_a[$i] eq "lo_hi_num_input") {
        print $table_output "  int  $list_name_a[$i]_lo\[$num_input\]\[$array_size\];\n";
        print $table_output "  int  $list_name_a[$i]_hi\[$num_input\]\[$array_size\];\n";
        print $table_output "  int  $list_name_a[$i]_wt\[$num_input\]\[$array_size\];\n\n";
      }
      if($list_func_a[$i] eq "lo_hi_num_input_strm") {
        print $table_output "  int  $list_name_a[$i]_lo\[$num_input\]\[$num_strm\]\[$array_size\];\n";
        print $table_output "  int  $list_name_a[$i]_hi\[$num_input\]\[$num_strm\]\[$array_size\];\n";
        print $table_output "  int  $list_name_a[$i]_wt\[$num_input\]\[$num_strm\]\[$array_size\];\n\n";
      }
    }
  }
  if($line_o =~ m/$GENERATE_FUNC_BEG/)                          #find the line with $GENERATE_FUNC_BEG
  {
    foreach my $i (0 .. $#list_name_a) {
      if($list_func_a[$i] eq "vl") {
        print $table_output "  CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_vl, MergeConst.$list_name_a[$i]_vl, CcbConstraintTableDefault::$list_name_a[$i]_vl, ReservedValue, DefaultValue);\n";
        print $table_output "  CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_wt, MergeConst.$list_name_a[$i]_wt, CcbConstraintTableDefault::$list_name_a[$i]_wt, ReservedValue, DefaultValue);\n\n";
      }
      if($list_func_a[$i] eq "enum") {
        print $table_output "  CcbConstTableTool #(.EnumType($list_enum_a[$i]))::SetConstValue_enum(this.$list_name_a[$i]_wt, MergeConst.$list_name_a[$i]_wt, CcbConstraintTableDefault::$list_name_a[$i]_wt, ReservedValue, DefaultValue);\n\n";
      }
      if($list_func_a[$i] eq "lo_hi") {
        print $table_output "  CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_lo, MergeConst.$list_name_a[$i]_lo, CcbConstraintTableDefault::$list_name_a[$i]_lo, ReservedValue, DefaultValue);\n";
        print $table_output "  CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_hi, MergeConst.$list_name_a[$i]_hi, CcbConstraintTableDefault::$list_name_a[$i]_hi, ReservedValue, DefaultValue);\n";
        print $table_output "  CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_wt, MergeConst.$list_name_a[$i]_wt, CcbConstraintTableDefault::$list_name_a[$i]_wt, ReservedValue, DefaultValue);\n\n";
      }
      if($list_func_a[$i] eq "vl_num_input") {
        print $table_output "  for (int i=0; i<$num_input ; i++) begin\n";
        print $table_output "    CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_vl[i], MergeConst.$list_name_a[$i]_vl[i], CcbConstraintTableDefault::$list_name_a[$i]_vl[i], ReservedValue, DefaultValue);\n";
        print $table_output "    CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_wt[i], MergeConst.$list_name_a[$i]_wt[i], CcbConstraintTableDefault::$list_name_a[$i]_wt[i], ReservedValue, DefaultValue);\n";
        print $table_output "  end\n\n";
      }
      if($list_func_a[$i] eq "enum_num_input") {
        print $table_output "  for (int i=0; i<$num_input ; i++) begin\n";
        print $table_output "    CcbConstTableTool #(.EnumType($list_enum_a[$i]))::SetConstValue_enum(this.$list_name_a[$i]_wt[i], MergeConst.$list_name_a[$i]_wt[i], CcbConstraintTableDefault::$list_name_a[$i]_wt[i], ReservedValue, DefaultValue);\n";
        print $table_output "  end\n\n";
      }
      if($list_func_a[$i] eq "enum_num_track") {
        print $table_output "  for (int i=0; i<$num_track ; i++) begin\n";
        print $table_output "    CcbConstTableTool #(.EnumType($list_enum_a[$i]))::SetConstValue_enum(this.$list_name_a[$i]_wt[i], MergeConst.$list_name_a[$i]_wt[i], CcbConstraintTableDefault::$list_name_a[$i]_wt[i], ReservedValue, DefaultValue);\n";
        print $table_output "  end\n\n";
      }
      if($list_func_a[$i] eq "lo_hi_num_input") {
        print $table_output "  for (int i=0; i<$num_input ; i++) begin\n";
        print $table_output "    CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_lo[i], MergeConst.$list_name_a[$i]_lo[i], CcbConstraintTableDefault::$list_name_a[$i]_lo[i], ReservedValue, DefaultValue);\n";
        print $table_output "    CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_hi[i], MergeConst.$list_name_a[$i]_hi[i], CcbConstraintTableDefault::$list_name_a[$i]_hi[i], ReservedValue, DefaultValue);\n";
        print $table_output "    CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_wt[i], MergeConst.$list_name_a[$i]_wt[i], CcbConstraintTableDefault::$list_name_a[$i]_wt[i], ReservedValue, DefaultValue);\n";
        print $table_output "  end\n\n";
      }
      if($list_func_a[$i] eq "lo_hi_num_input_strm") {
        print $table_output "  for (int i=0; i<$num_input ; i++) begin\n";
        print $table_output "    for (int j=0; j<$num_strm ; j++) begin\n";
        print $table_output "      CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_lo[i][j], MergeConst.$list_name_a[$i]_lo[i][j], CcbConstraintTableDefault::$list_name_a[$i]_lo[i][j], ReservedValue, DefaultValue);\n";
        print $table_output "      CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_hi[i][j], MergeConst.$list_name_a[$i]_hi[i][j], CcbConstraintTableDefault::$list_name_a[$i]_hi[i][j], ReservedValue, DefaultValue);\n";
        print $table_output "      CcbConstTableTool  #(.ArrSize($array_size))::SetConstValue_array(this.$list_name_a[$i]_wt[i][j], MergeConst.$list_name_a[$i]_wt[i][j], CcbConstraintTableDefault::$list_name_a[$i]_wt[i][j], ReservedValue, DefaultValue);\n";
        print $table_output "    end\n";
        print $table_output "  end\n\n";
      }
    }
  }
  if($line_o =~ m/$GENERATE_PRINT_BEG/)                          #find the line with $GENERATE_PRINT_BEG
  {
    foreach my $i (0 .. $#list_name_a) {
      if($list_func_a[$i] eq "vl") {
        print $table_output "  str = \"\";\n";
        print $table_output "  for (int j=0; j<$array_size; j++) begin\n";
        print $table_output "    \$sformat(str, {str, \"%0h:%0d, \"}, this.$list_name_a[$i]_vl[j], this.$list_name_a[$i]_wt[j]);\n";
        print $table_output "  end\n";
        print $table_output "  \$sformat(final_str, {final_str, \"$list_name_a[$i]: { \%s }\\n \"},str);\n\n";
      }
      if($list_func_a[$i] eq "enum") {
        print $table_output "  str = \"\";\n";
        print $table_output "  str = CcbConstTableTool #(.EnumType($list_enum_a[$i]))::ConstPrint_enum(this.$list_name_a[$i]_wt);\n";
        print $table_output "  \$sformat(final_str, {final_str, \"$list_name_a[$i]: { %s }\\n \"}, str);\n\n";
      }
      if($list_func_a[$i] eq "lo_hi") {
        print $table_output "  str = \"\";\n";
        print $table_output "  for (int j=0; j<$array_size; j++) begin\n";
        print $table_output "    \$sformat(str, {str, \"[%0h:%0h]:%0d  \"}, this.$list_name_a[$i]_lo[j], this.$list_name_a[$i]_hi[j], this.$list_name_a[$i]_wt[j]);\n";
        print $table_output "  end\n";
        print $table_output "  \$sformat(final_str, {final_str, \"$list_name_a[$i]: { %s }\\n \"},str);\n\n";
      }
      if($list_func_a[$i] eq "vl_num_input") {
        print $table_output "  for (int i=0; i<$num_input ; i++) begin\n";
        print $table_output "    str = \"\";\n";
        print $table_output "    for (int j=0; j<$array_size; j++) begin\n";
        print $table_output "      \$sformat(str, {str, \"%0h:%0d, \"}, this.$list_name_a[$i]_vl[i][j], this.$list_name_a[$i]_wt[i][j]);\n";
        print $table_output "    end\n";
        print $table_output "    \$sformat(final_str, {final_str, \"$list_name_a[$i]\[%0d\]: { \%s }\\n \"},i ,str);\n\n";
        print $table_output "  end\n\n";
      }
      if($list_func_a[$i] eq "enum_num_input") {
        print $table_output "  str = \"\";\n";
        print $table_output "  for (int i=0; i<$num_input ; i++) begin\n";
        print $table_output "    str = CcbConstTableTool #(.EnumType($list_enum_a[$i]))::ConstPrint_enum(this.$list_name_a[$i]_wt[i]);\n";
        print $table_output "    \$sformat(final_str, {final_str, \"$list_name_a[$i]\[%0d\]: { %s }\\n \"},i ,str);\n";
        print $table_output "  end\n\n";
      }
      if($list_func_a[$i] eq "enum_num_track") {
        print $table_output "  str = \"\";\n";
        print $table_output "  for (int i=0; i<$num_track ; i++) begin\n";
        print $table_output "    str = CcbConstTableTool #(.EnumType($list_enum_a[$i]))::ConstPrint_enum(this.$list_name_a[$i]_wt[i]);\n";
        print $table_output "    \$sformat(final_str, {final_str, \"$list_name_a[$i]\[%0d\]: { %s }\\n \"},i ,str);\n";
        print $table_output "  end\n\n";
      }
      if($list_func_a[$i] eq "lo_hi_num_input") {
        print $table_output "  for (int i=0; i<$num_input ; i++) begin\n";
        print $table_output "    str = \"\";\n";
        print $table_output "    for (int j=0; j<$array_size; j++) begin\n";
        print $table_output "      \$sformat(str, {str, \"[%0h:%0h]:%0d  \"}, this.$list_name_a[$i]_lo[i][j], this.$list_name_a[$i]_hi[i][j], this.$list_name_a[$i]_wt[i][j]);\n";
        print $table_output "    end\n";
        print $table_output "    \$sformat(final_str, {final_str, \"$list_name_a[$i]\[%0d\]: { %s }\\n \"},i ,str);\n";
        print $table_output "  end\n\n";
      }
      if($list_func_a[$i] eq "lo_hi_num_input_strm") {
        print $table_output "  for (int i=0; i<$num_input ; i++) begin\n";
        print $table_output "    for (int j=0; j<$num_strm ; j++) begin\n";
        print $table_output "      str = \"\";\n";
        print $table_output "      for (int k=0; k<$array_size; k++) begin\n";
        print $table_output "        \$sformat(str, {str, \"[%0h:%0h]:%0d  \"}, this.$list_name_a[$i]_lo[i][j][k], this.$list_name_a[$i]_hi[i][j][k], this.$list_name_a[$i]_wt[i][j][k]);\n";
        print $table_output "      end\n";
        print $table_output "      \$sformat(final_str, {final_str, \"$list_name_a[$i]\[%0d\]\[%0d\]: { %s }\\n \"},i, j,str);\n";
        print $table_output "    end\n";
        print $table_output "  end\n\n";
      }
    }
  }
}

# This while scan DaxCcbConstraint_Templete to generate DaxCcbConstraint.sv
while ($line_o = <$const>) {                                      #scan the whole const file
  print $const_output $line_o;                                          #build new source file
  if($line_o =~ m/$GENERATE_CONST_BEG/)                          #find the line with $GENERATE_CONST_BEG
  {
    foreach my $i (0 .. $#list_name_a) {
      if($list_func_a[$i] eq "vl") {
        print $const_output "  $list_name_a[$i] dist{\n";
        print $const_output "    ccbConst.$list_name_a[$i]_vl[0] := ccbConst.$list_name_a[$i]_wt[0],\n";
        print $const_output "    ccbConst.$list_name_a[$i]_vl[1] := ccbConst.$list_name_a[$i]_wt[1],\n";
        print $const_output "    ccbConst.$list_name_a[$i]_vl[2] := ccbConst.$list_name_a[$i]_wt[2],\n";
        print $const_output "    ccbConst.$list_name_a[$i]_vl[3] := ccbConst.$list_name_a[$i]_wt[3],\n";
        print $const_output "    ccbConst.$list_name_a[$i]_vl[4] := ccbConst.$list_name_a[$i]_wt[4],\n";
        print $const_output "    ccbConst.$list_name_a[$i]_vl[5] := ccbConst.$list_name_a[$i]_wt[5],\n";
        print $const_output "    ccbConst.$list_name_a[$i]_vl[6] := ccbConst.$list_name_a[$i]_wt[6],\n";
        print $const_output "    ccbConst.$list_name_a[$i]_vl[7] := ccbConst.$list_name_a[$i]_wt[7]\n";
        print $const_output "  };\n\n";
      }
      if($list_func_a[$i] eq "enum") {
      }
      if($list_func_a[$i] eq "lo_hi") {
        print $const_output "  $list_name_a[$i] dist{\n";
        print $const_output "    [ccbConst.$list_name_a[$i]_lo[0] : ccbConst.$list_name_a[$i]_hi[0]] :/ ccbConst.$list_name_a[$i]_wt[0],\n";
        print $const_output "    [ccbConst.$list_name_a[$i]_lo[1] : ccbConst.$list_name_a[$i]_hi[1]] :/ ccbConst.$list_name_a[$i]_wt[1],\n";
        print $const_output "    [ccbConst.$list_name_a[$i]_lo[2] : ccbConst.$list_name_a[$i]_hi[2]] :/ ccbConst.$list_name_a[$i]_wt[2],\n";
        print $const_output "    [ccbConst.$list_name_a[$i]_lo[3] : ccbConst.$list_name_a[$i]_hi[3]] :/ ccbConst.$list_name_a[$i]_wt[3],\n";
        print $const_output "    [ccbConst.$list_name_a[$i]_lo[4] : ccbConst.$list_name_a[$i]_hi[4]] :/ ccbConst.$list_name_a[$i]_wt[4],\n";
        print $const_output "    [ccbConst.$list_name_a[$i]_lo[5] : ccbConst.$list_name_a[$i]_hi[5]] :/ ccbConst.$list_name_a[$i]_wt[5],\n";
        print $const_output "    [ccbConst.$list_name_a[$i]_lo[6] : ccbConst.$list_name_a[$i]_hi[6]] :/ ccbConst.$list_name_a[$i]_wt[6],\n";
        print $const_output "    [ccbConst.$list_name_a[$i]_lo[7] : ccbConst.$list_name_a[$i]_hi[7]] :/ ccbConst.$list_name_a[$i]_wt[7]\n";
        print $const_output "  };\n\n";
      }
      if($list_func_a[$i] eq "vl_num_input") {
        print $const_output "  foreach($list_name_a[$i]\[i\]) {\n";
        print $const_output "    $list_name_a[$i]\[i\] dist{\n";
        print $const_output "      ccbConst.$list_name_a[$i]_vl[i][0] := ccbConst.$list_name_a[$i]_wt[i][0],\n";
        print $const_output "      ccbConst.$list_name_a[$i]_vl[i][1] := ccbConst.$list_name_a[$i]_wt[i][1],\n";
        print $const_output "      ccbConst.$list_name_a[$i]_vl[i][2] := ccbConst.$list_name_a[$i]_wt[i][2],\n";
        print $const_output "      ccbConst.$list_name_a[$i]_vl[i][3] := ccbConst.$list_name_a[$i]_wt[i][3],\n";
        print $const_output "      ccbConst.$list_name_a[$i]_vl[i][4] := ccbConst.$list_name_a[$i]_wt[i][4],\n";
        print $const_output "      ccbConst.$list_name_a[$i]_vl[i][5] := ccbConst.$list_name_a[$i]_wt[i][5],\n";
        print $const_output "      ccbConst.$list_name_a[$i]_vl[i][6] := ccbConst.$list_name_a[$i]_wt[i][6],\n";
        print $const_output "      ccbConst.$list_name_a[$i]_vl[i][7] := ccbConst.$list_name_a[$i]_wt[i][7]\n";
        print $const_output "    };\n";
        print $const_output "  }\n\n";
      }
      if($list_func_a[$i] eq "enum_num_input") {
      }
      if($list_func_a[$i] eq "enum_num_track") {
      }
      if($list_func_a[$i] eq "lo_hi_num_input") {
        print $const_output "  foreach($list_name_a[$i]\[i\]) {\n";
        print $const_output "    $list_name_a[$i]\[i\] dist{\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][0] : ccbConst.$list_name_a[$i]_hi[i][0]] :/ ccbConst.$list_name_a[$i]_wt[i][0],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][1] : ccbConst.$list_name_a[$i]_hi[i][1]] :/ ccbConst.$list_name_a[$i]_wt[i][1],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][2] : ccbConst.$list_name_a[$i]_hi[i][2]] :/ ccbConst.$list_name_a[$i]_wt[i][2],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][3] : ccbConst.$list_name_a[$i]_hi[i][3]] :/ ccbConst.$list_name_a[$i]_wt[i][3],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][4] : ccbConst.$list_name_a[$i]_hi[i][4]] :/ ccbConst.$list_name_a[$i]_wt[i][4],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][5] : ccbConst.$list_name_a[$i]_hi[i][5]] :/ ccbConst.$list_name_a[$i]_wt[i][5],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][6] : ccbConst.$list_name_a[$i]_hi[i][6]] :/ ccbConst.$list_name_a[$i]_wt[i][6],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][7] : ccbConst.$list_name_a[$i]_hi[i][7]] :/ ccbConst.$list_name_a[$i]_wt[i][7]\n";
        print $const_output "    };\n";
        print $const_output "  }\n\n";
      }
      if($list_func_a[$i] eq "lo_hi_num_input_strm") {
        print $const_output "  foreach($list_name_a[$i]\[i,j\]) {\n";
        print $const_output "    $list_name_a[$i]\[i\]\[j\] dist{\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][j][0] : ccbConst.$list_name_a[$i]_hi[i][j][0]] :/ ccbConst.$list_name_a[$i]_wt[i][j][0],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][j][1] : ccbConst.$list_name_a[$i]_hi[i][j][1]] :/ ccbConst.$list_name_a[$i]_wt[i][j][1],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][j][2] : ccbConst.$list_name_a[$i]_hi[i][j][2]] :/ ccbConst.$list_name_a[$i]_wt[i][j][2],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][j][3] : ccbConst.$list_name_a[$i]_hi[i][j][3]] :/ ccbConst.$list_name_a[$i]_wt[i][j][3],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][j][4] : ccbConst.$list_name_a[$i]_hi[i][j][4]] :/ ccbConst.$list_name_a[$i]_wt[i][j][4],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][j][5] : ccbConst.$list_name_a[$i]_hi[i][j][5]] :/ ccbConst.$list_name_a[$i]_wt[i][j][5],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][j][6] : ccbConst.$list_name_a[$i]_hi[i][j][6]] :/ ccbConst.$list_name_a[$i]_wt[i][j][6],\n";
        print $const_output "      [ccbConst.$list_name_a[$i]_lo[i][j][7] : ccbConst.$list_name_a[$i]_hi[i][j][7]] :/ ccbConst.$list_name_a[$i]_wt[i][j][7]\n";
        print $const_output "    };\n";
        print $const_output "  }\n\n";
      }
    }
  }

}

print "UPDATE finish\n";
close $table;
close $list;
close $table_output;
close $const_output;
