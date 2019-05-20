#!/usr/bin/perl
#
# Compare two windows registry export .reg files
# ANA Technology Partner
# Created: 05/2019
#
# Usage: perl regdiffexplorer.pl pre.reg post.reg
# Output lines:
# [M] Key Modified: <registry key>: <subkey>: <pre value> <post value>
# [D] Key Deleted: <registry key>: <subkey>: <key value>
# [A] Key Added: <registry key>: <subkey>: <key value>
# 

my $editor_comment = "Windows Registry Editor Version";
my %reg1 = (); # PRE
my %reg2 = (); # POST
my $current_location = "";
my $key = "";
my $value = "";
my $multiline = 0;
my $part = "";

sub reset_multiline{
	$multiline = 0;
}

sub load_value{
	if($multiline){
		# Reset Multi Line flag as data is loaded
		reset_multiline();
	}

	chomp $value;
	
	my $hash = shift;
	if($hash =~ /reg1/){
		#print "Load-> $hash:$current_location:$key:$value\n";
		$reg1{$current_location}{$key} = $value;
	}
	elsif($hash =~ /reg2/){
		$reg2{$current_location}{$key} = $value;
	}
}

sub print_hash{
	my $hash = shift;
	if ($hash =~ /reg1/){
		foreach my $reg (sort keys %reg1){
			foreach my $key (sort keys %{$reg1{$reg}}){
				my $value = $reg1{$reg}{$key};
				chomp $value;
				print "$reg: $key: $value\n";
			}
		}
	}
	if ($hash =~ /reg2/){
		foreach my $reg (sort keys %reg2){
			foreach my $key (sort keys %{$reg2{$reg}}){
				my $value = $reg2{$reg}{$key};
				chomp $value;
				print "$reg: $key: $value\n";
			}
		}
	}
}

# Display registry keys that changed
# 
sub explore_all_reg{
	my @changes = ();
	#Find pre entries that are different now
	foreach my $reg (sort keys %reg1){
		push(@changes, $reg);
		#print "$reg\n";
	}

	foreach my $i (0 .. $#changes) {
		my $j = $i + 1;
  		print "[$j]. $changes[$i]\n";
	}
	print "\n[b]. Back to Main Menu\n";

	print "\n\n Select entry to explore: ";
	my $explore_answer = <STDIN>;
	chomp $explore_answer;

	while($explore_answer ne "b"){

		my $selected_index = $explore_answer - 1;
		my $selected_reg = $changes[$selected_index];

		print "=== EXPLORE RESULTS [$selected_reg] ===\n\n";

		print "[PRE]\n";
		foreach my $key (sort keys %{$reg1{$selected_reg}}){
			print "$key: $reg1{$selected_reg}{$key}\n";
		}
		print "\n[POST]\n";
		foreach my $key (sort keys %{$reg2{$selected_reg}}){
			print "$key: $reg2{$selected_reg}{$key}\n";
		}
		print "\n=== EXPLORE REULTS END [$selected_reg] ===\n\n";

		print "Enter to continue ...\n";
		<STDIN>;

		foreach my $i (0 .. $#changes) {
			my $j = $i + 1;
			print "[$j]. $changes[$i]\n";
		}
		print "\n[b]. Back to Main Menu\n";

		print "\n\n Select entry to explore: ";
		$explore_answer = <STDIN>;
		chomp $explore_answer;

	}
}

# Filtered Search on PRE registry
sub explore_reg_key_or_val_filtered_pre{

	# only reg1 keys are filtered
	# [TO-DO: Add any additional keys from REG2]
	my $filters = shift;
	my @filter = split(/\^/,$filters);
	my $key_count = 0;
	my $subkey_count = 0;
	my @changes = ();

	my $reg_hex_search = registry_search_ascii_to_hex($filter[0]);

	if ((scalar @filter > 1) && ($filter[1] eq "i")){
		#Find pre entries that are different now (Case Insensitive Filter)
		print "Filter (Case Insensitive): $filter[0] OR $reg_hex_search. Searching ... \n";
		foreach my $key (sort keys %reg1){
			my $pushed = 0; # Needed to restrict subkey related match push of dup key
			if ($key =~ /$filter[0]/i){
				push(@changes, $key);
			}
			#search all subkeys and values and still push if match found
			else{
				#subkey pattern match [Case Insensitive]
				foreach my $subkey (keys %{$reg1{$key}}){
					if (($pushed == 0) && ($subkey =~ /$filter[0]/i)){
						push(@changes, $key);
						$pushed = 1;
					}
					#subkey value pattern match
					elsif(($pushed == 0) && ($reg1{$key}{$subkey} =~ /$filter[0]/i)){
						push(@changes, $key);
						$pushed = 1;
					}
				}
			}
		}
	} 
	# Case sensitive search
	else {
		#Find pre entries that are different now
		print "Filter (Case Sensitive): $filter[0] OR $reg_hex_search. Searching ... \n";
		
		foreach my $key (sort keys %reg1) {
			#initialize pushed for each key
			$pushed = 0;
			#print "matching key: $key\n";
			$key_count++;
			if ($key =~ /$filter[0]/){
				push(@changes, $key);
			}
			#search all subkeys and values and still push if match found
			else{
				#subkey pattern match [Case Sensitive]
				foreach my $subkey (keys %{$reg1{$key}}){
					$subkey_count++;
					if (($pushed == 0) && (($subkey =~ /$filter[0]/) || ($subkey =~ /$reg_hex_search/)) ){
						push(@changes, $key);
						$pushed = 1;
					}
					#subkey value pattern match
					elsif(($pushed == 0) && (($reg1{$key}{$subkey} =~ /$filter[0]/) || ($reg1{$key}{$subkey} =~ /$reg_hex_search/)) ){
						push(@changes, $key);
						$pushed = 1;
					}
				}
			}
		}	
	}

	print "Seached keys: $key_count, Sub Keys: $subkey_count\n\n";

	# unique entries
	my @unique_changes = ();
	my %tmp = ();
	foreach my $v (@changes){
		if(!exists $tmp{$v}){
			$tmp{$v} = '1';
			push(@unique_changes, $v);
		}
	}

	foreach my $i (0 .. $#unique_changes) {
		my $j = $i + 1;
  		print "[$j]. $unique_changes[$i]\n";
	}
	print "\n[b]. Back to Main Menu\n";

	print "\n\n Select entry to explore: ";
	my $explore_answer = <STDIN>;
 
	while ($explore_answer != "x"){
		my $selected_index = $explore_answer - 1;
		my $selected_reg = $unique_changes[$selected_index];

		print "=== FILTERED EXPLORE [Filter: $filter[0]] [$selected_reg] ===\n\n";

		print "[PRE]\n";
		foreach my $key (sort keys %{$reg1{$selected_reg}}){
			print "$key: $reg1{$selected_reg}{$key}\n";
			#hex_to_ascii_for_entry($reg1{$selected_reg}{$key});
		}
		print "\n[POST]\n";
		foreach my $key (sort keys %{$reg2{$selected_reg}}){
			print "$key: $reg2{$selected_reg}{$key}\n";
		}

		print "\n=== EXPLORE REULTS END [$selected_reg] ===\n\n";

		print "Enter to Continue ...\n";
		<STDIN>;

		foreach my $i (0 .. $#unique_changes) {
			my $j = $i + 1;
			print "[$j]. $unique_changes[$i]\n";
		}
		print "\n[b]. Back to Main Menu\n";
		print "\n\n Select entry to explore: ";
		$explore_answer = <STDIN>;
		chomp $explore_answer;
	}
	

}

# Filtered Search on POST registry
sub explore_reg_key_or_val_filtered_post{

	# only reg1 keys are filtered
	# [TO-DO: Add any additional keys from REG2]
	my $filters = shift;
	my @filter = split(/\^/,$filters);
	my $key_count = 0;
	my $subkey_count = 0;
	my @changes = ();

	my $reg_hex_search = registry_search_ascii_to_hex($filter[0]);

	if ((scalar @filter > 1) && ($filter[1] eq "i")){
		#Find pre entries that are different now (Case Insensitive Filter)
		print "Filter (Case Insensitive): $filter[0] OR $reg_hex_search. Searching ... \n";
		foreach my $key (sort keys %reg2){
			my $pushed = 0; # Needed to restrict subkey related match push of dup key
			if ($key =~ /$filter[0]/i){
				push(@changes, $key);
			}
			#search all subkeys and values and still push if match found
			else{
				#subkey pattern match [Case Insensitive]
				foreach my $subkey (keys %{$reg2{$key}}){
					if (($pushed == 0) && ($subkey =~ /$filter[0]/i)){
						push(@changes, $key);
						$pushed = 1;
					}
					#subkey value pattern match
					elsif(($pushed == 0) && ($reg2{$key}{$subkey} =~ /$filter[0]/i)){
						push(@changes, $key);
						$pushed = 1;
					}
				}
			}
		}
	} 
	# Case sensitive search
	else {
		#Find pre entries that are different now
		print "Filter (Case Sensitive): $filter[0] OR $reg_hex_search. Searching ... \n";
		
		foreach my $key (sort keys %reg2) {
			#initialize pushed for each key
			$pushed = 0;
			#print "matching key: $key\n";
			$key_count++;
			if ($key =~ /$filter[0]/){
				push(@changes, $key);
			}
			#search all subkeys and values and still push if match found
			else{
				#subkey pattern match [Case Sensitive]
				foreach my $subkey (keys %{$reg2{$key}}){
					$subkey_count++;
					if (($pushed == 0) && (($subkey =~ /$filter[0]/) || ($subkey =~ /$reg_hex_search/)) ){
						push(@changes, $key);
						$pushed = 1;
					}
					#subkey value pattern match
					elsif(($pushed == 0) && (($reg2{$key}{$subkey} =~ /$filter[0]/) || ($reg2{$key}{$subkey} =~ /$reg_hex_search/)) ){
						push(@changes, $key);
						$pushed = 1;
					}
				}
			}
		}	
	}

	print "Seached keys: $key_count, Sub Keys: $subkey_count\n\n";

	# unique entries
	my @unique_changes = ();
	my %tmp = ();
	foreach my $v (@changes){
		if(!exists $tmp{$v}){
			$tmp{$v} = '1';
			push(@unique_changes, $v);
		}
	}

	foreach my $i (0 .. $#unique_changes) {
		my $j = $i + 1;
  		print "[$j]. $unique_changes[$i]\n";
	}
	print "\n[b]. Back to Main Menu\n";

	print "\n\n Select entry to explore: ";
	my $explore_answer = <STDIN>;
 
	while ($explore_answer != "x"){
		my $selected_index = $explore_answer - 1;
		my $selected_reg = $unique_changes[$selected_index];

		print "=== FILTERED EXPLORE [Filter: $filter[0]] [$selected_reg] ===\n\n";

		print "[PRE]\n";
		foreach my $key (sort keys %{$reg1{$selected_reg}}){
			print "$key: $reg1{$selected_reg}{$key}\n";
			#hex_to_ascii_for_entry($reg1{$selected_reg}{$key});
		}
		print "\n[POST]\n";
		foreach my $key (sort keys %{$reg2{$selected_reg}}){
			print "$key: $reg2{$selected_reg}{$key}\n";
		}

		print "\n=== EXPLORE REULTS END [$selected_reg] ===\n\n";

		print "Enter to Continue ...\n";
		<STDIN>;

		foreach my $i (0 .. $#unique_changes) {
			my $j = $i + 1;
			print "[$j]. $unique_changes[$i]\n";
		}
		print "\n[b]. Back to Main Menu\n";
		print "\n\n Select entry to explore: ";
		$explore_answer = <STDIN>;
		chomp $explore_answer;
	}
}

# Compare PRE -> POST and identify modified
# key comparing to PRE
sub explore_mods{
	my @mods = ();
	#Find pre entries that are different now
		foreach my $reg (sort keys %reg1){
			foreach my $key (sort keys %{$reg1{$reg}}){
				my $old_value = $reg1{$reg}{$key};
				chomp $old_value;
				
				if(exists $reg2{$reg}{$key}){
					my $new_value = $reg2{$reg}{$key};
					chomp $new_value;

					#PRE's value different than POST
					if($old_value ne $new_value){
						push(@mods, $reg);
						#print "[M] Key Modified: $reg\n";
						# printf "%-20s %-11s %-11s %-11s\n", $$reg, $$key, $old_value, $new_value;
						# print "[M] Key Modified: $reg,$key,$old_value,$new_value\n";
						# print "[M] Registry Location: $reg\n";
						# print "[M] Sub Key Name: $key\n";
						# print "[M] Old Value: $old_value\n";
						# print "[M] New Value: $new_value\n";
					}
					
				} else {
					# Missing section - removed to its own menu
					# push(@mods, $reg);
					# print ("[D] Key Deleted: $reg:$key\n");
				}
				
			}
		}

	# unique entries
	my @unique_mods = ();
	my %tmp = ();
	foreach my $v (@mods){
		if(!exists $tmp{$v}){
			$tmp{$v} = '1';
			push(@unique_mods, $v);
		}
	}

	# print mods and deletes menu
		foreach my $i (0 .. $#unique_mods) {
		my $j = $i + 1;
  		print "[$j]. $unique_mods[$i]\n";
	}
	print "\n[b]. Back to Main Menu\n";

	print "\n\n Select entry to explore: ";
	my $mods_explore_answer = <STDIN>;
	chomp $mods_explore_answer;


	while($mods_explore_answer ne "b"){

		my $selected_index = $mods_explore_answer - 1;
		my $selected_reg = $unique_mods[$selected_index];
		print "=== DIFF EXPLORE [$selected_reg] ===\n\n";

		foreach my $key (sort keys %{$reg1{$selected_reg}}){
			my $old_value = $reg1{$selected_reg}{$key};
			chomp $old_value;
					
			if(exists $reg2{$selected_reg}{$key}){
				my $new_value = $reg2{$selected_reg}{$key};
				chomp $new_value;

				#PRE's value different than POST
				if($old_value ne $new_value){
					# print "[M] Key Modified: $key,$old_value,$new_value\n";
					# print "[M] Registry Location: $reg\n";
					print "[M] Sub Key Name: $key\n";
					print "[M] Old Value: $old_value\n";
					print "[M] New Value: $new_value\n\n";
					}
						
				} else {
						print "[D] Key Deleted: $key\n";
						print "[D] Value: $old_Value\n\n";
				}	
		}

		print "\n=== DIFF EXPLORE END [$selected_reg] ===\n\n";
		print "Enter to Continue ...\n";
		<STDIN>;

		# print mods and deletes menu
		foreach my $i (0 .. $#unique_mods) {
			my $j = $i + 1;
  			print "[$j]. $unique_mods[$i]\n";
		}
		print "\n[b]. Back to Main Menu\n";

		# [TO-DO -- deletes]
		print "\n\n Select entry to explore: ";
		$mods_explore_answer = <STDIN>;
		chomp $mods_explore_answer;

	}
}

# Compare POST -> PRE and identify any New or modified
# key compared to POST
sub identify_new{

	#Find pre entries that are different now
		foreach my $reg (sort keys %reg2){
			foreach my $key (sort keys %{$reg2{$reg}}){
				if(!exists $reg1{$reg}{$key}){
					print ("[A] Key Added: $reg:$key:$reg2{$reg}{$key}\n");
				}
			}
		}
}

# Deleted Keys only
sub identify_deleted{

	#Find pre entries that are different now
	foreach my $reg (sort keys %reg1){
		foreach my $key (sort keys %{$reg1{$reg}}){
			my $old_value = $reg1{$reg}{$key};
			chomp $old_value;
			
			if(!exists $reg2{$reg}{$key}){
				print ("[D] Key Deleted: $reg:$key:$reg1{$reg}{$key}\n");
			}
			
		}
	}
}

sub csv_missing_mod{

	my $filename = shift;
	print "Opening file $filename for write\n";
	open(FILE, "> $filename") || die "Unable to open file $filename for write. Exiting.";

	#Find pre entries that are different now
		foreach my $reg (sort keys %reg1){
			foreach my $key (sort keys %{$reg1{$reg}}){
				my $old_value = $reg1{$reg}{$key};
				chomp $old_value;
				
				if(exists $reg2{$reg}{$key}){
					my $new_value = $reg2{$reg}{$key};
					chomp $new_value;

					#PRE's value different than POST
					if($old_value ne $new_value){
						print FILE "[M] Key Modified: $reg: $key: $old_value: $new_value\n";
						# print "[M] Key Modified: $reg,$key,$old_value,$new_value\n";
						# print "[M] Registry Location: $reg\n";
						# print "[M] Sub Key Name: $key\n";
						# print "[M] Old Value: $old_value\n";
						# print "[M] New Value: $new_value\n";
					}
					
				} else {
					print FILE "[D] Key Deleted: $reg:$key\n";
				}
				
			}
		}
	close(FILE);
}

sub csv_new{

	my $filename = shift;
	open(FILE, ">> $filename") || die "Unable to open file $filename for write. Exiting.";

	#Find pre entries that are different now
		foreach my $reg (sort keys %reg2){
			foreach my $key (sort keys %{$reg2{$reg}}){
				if(!exists $reg1{$reg}{$key}){
					print FILE "[A] Key Added: $reg:$key:$reg2{$reg}{$key}\n";
				}
			}
		}
	print "Closing file $filename - DONE\n";
	close(FILE);
}

sub read_reg{

	my $which_hash = shift; #reg1 or reg2

	#PRE File
	if($which_hash =~ /reg1/){
		my $file = $ARGV[0];
		open(F1, '<:encoding(UTF-16)', $file) || die "Unable to load registry export at $ARGV[0]\n";
	}
	#POST File
	elsif($which_hash =~ /reg2/){
		my $file = $ARGV[1];
		open(F1, '<:encoding(UTF-16)', $file) || die "Unable to load registry export at $ARGV[1]\n";
	}else{
		print "Syntax Error:\n";
	}


	#print "Reading file: $ARGV[0]\n";
	while(<F1>){
		my $line = $_;
		chomp $line;
		#print "Line: $line\n";
		#Ignore Comments Line
		if($line =~ /$editor_comment/){
			#do nothing
			#print "Comment Found\n";
		}
		# SET NEW REG ENTRY LOCATION
		elsif($line =~ /^\[(.*)\]/){
			# print "New reg found\n";
			# For Safety. If new Reg Key located
			# Just make sure multiline flag is not set. If set flush.
			# This should not happen since a blank line or a new key
			# for the same hash should already flush the buffer.
			if($multiline){
				# Flush multiline into hash
				# This should not occur as multival should be zero
				load_value($which_hash);
			}
			# Set Current Registry Location being analyzed
			$current_location = $1;
			#print "$current_location\n";
		}
		# BUFFER STARTED LOGIC
		# if value is multiline split ending with backslash \
		# buffer value for the key and flush when new hive location OR key pattern
		# is encountered
		elsif($line =~ /^(.*)\=(.*)\\(\s+)$/){
			$key = $1;
			# value buffer initialized
			$value = $2;
			$multiline = 1;
			#print "$key:$value\n";
		}
		# SINGLE LINE KV
		# if value is in a single line
		elsif($line =~ /^(.*)\=(.*)$/){
			# #DEBUG
			# if($line =~ /UninstallString\"=\"D/){
			# 	print "[DEBUG] $line\n";
			# }
			#if multiline - Flush last value before new capture
			# this should not occur

			if($multiline){
				load_value($which_hash);
			}
			
			#Identitfy Key/Values
			$key = $1;
			$value = $2;
			
			# Load Value into hash
			load_value($which_hash);
		}
		# BLANK LINE
		# flush into hash if ^$ and multiline
		elsif($line =~ /^$/){
			if($multiline){
				# Flush multiline into hash
				# This should also not occur as multiline would be zero
				load_value($which_hash);
			}
			# No other action needed
		}
		# ADD TO BUFFER LOGIC
		elsif($line =~ /^\s+(.*)\\/){
			if($multiline){
				my $part = $1;
				$value = $value . $part;
				# Addng Where print
				# print "Where: ADD to BUFFER LOGIC";
				# print "$part\n";
			}
			else{
				# Only occurs for pattern where value is split on multiple 
				# lines and ends with a double quote
				# Also consider it a multiline text
				# Buffer will get flushed automatically when new KV pair is 
				# encountered.
				#
				# Ex: "Data"="<DataCollectorSet>
				#   			<Status>0</Status>
				# 				<Duration>0</Duration>
				# 				<Description>Server Manager performance monitoring data collector set</Description>
				# 				<DescriptionUnresolved>Server Manager performance monitoring data collector set</DescriptionUnresolved>   
				# 				<DisplayName>Server Manager Performance Monitor</DisplayName>
				# 				<DisplayNameUnresolved>Server Manager Performance Monitor</DisplayNameUnresolved>
				# 				<SchedulesEnabled>-1</SchedulesEnabled>
				# 				<LatestOutputLocation/>"
				#
				# Set multipart flag
				$multiline = 1;
				my $part = $1;
				$value = $value . $part;
				# print "[ERROR]-- something went wrong!! --\n";
				# print "[ERROR]-- $current_location\n";
				# print "[ERROR]-- $line\n";
			}
		}
		# END OF NATURAL BUFFER PARTS
		# elsif sequence matters
		elsif($line =~ /^\s+(.*)/){
			$part = $1;
			if($multiline){
				#print "END of BUFFER\n";
				#print "line:$line\n";
				$value = $value . $part;
				#print "$key:$value\n";
				load_value($which_hash);
			}
		}
		else{
			#print "No Pattern Match: $line\n";
		}
	}
	close(F1);
}

sub banner{
	print "\n";
	print "==========================================================================\n";
	print "            Windows Registry Diff Explorer [v1.5]                          \n";
	print "              By ANA Technology Partner                              \n";
	print "                https://anapartner.com                                \n";
	print "	 Feedback/Contact: support\@anapartner.com                       \n";
	print "===========================================================================\n\n";

	print "Copyright 2019 ANA Technology Partner, Inc.\n\n";

	print "This program is free software: you can redistribute it and/or modify\n";
    print "it under the terms of the GNU General Public License as published by\n";
    print "the Free Software Foundation, either version 3 of the License, or\n";
    print "any later version.\n\n";

    print "This program is distributed in the hope that it will be useful,\n";
    print "but WITHOUT ANY WARRANTY; without even the implied warranty of\n";
    print "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n";
    print "GNU General Public License https://www.gnu.org/licenses/ for more details.\n\n";

	print "===========================================================================\n";
}

sub show_menu{
	print "\nSelect an option from the below menu:\n\n";
	print "[1]. Explore ALL Registry Keys (PRE & POST subkey/values)\n";
	print "[2]. Explore Modified Keys Only (PRE & POST subkey/values)\n";
	print "[3]. Display New Keys Only (Key:Subkey:Value)\n";
	print "[4]. Display Deleted Keys Only (Key:Subkey:Value)\n";
	print "[5]. Search Keys/Subkeys/Values with text pattern on PRE\n";
	print "[6]. Search Keys/Subkeys/Values with text pattern on POST\n";
	print "[7]. Export all differences to file (mod/add/rem)\n";
	print "[8]. Help\n";
	print "\n[x]. Exit\n\n";

	print "Enter Choice: ";
	my $answer = <STDIN>;
	chomp $answer;
	return $answer;
}

sub registry_search_ascii_to_hex{
    my $input = shift;
    my @characters = split(//,$input);

    # to Hex
    foreach my $char (@characters){
        $char = unpack "H*", $char;
    }

    # Pad with 00 after each hex char
    my $new_search = '';
    foreach my $c (@characters){
        $new_search = $new_search . $c . "," . "00,";
    }
    chop $new_search;
    return $new_search;
}

sub hex_to_ascii_for_entry{
	#"Contact": hex(2):43,00,41,00,00,00
	my $content = shift;
	if($content =~ /(.*)hex\(2\)\:(.*)/){
		my $hex_string = $2;
		my @characters = split(//,$hex_string);


		# [TO-DO] Remove null 00 and create a new string before decode
		my @clean = ();
		foreach my $bit (@characters){
			if ($bit ne "00"){
				push(@clean, $bit);
			}
		}
		# to ascii
		foreach my $char(@clean){
			$char = pack "H*", $char;
		}
		print "Un Hexed: ";
		foreach my $c(@clean){
			print "$c";
		}
		print "\n"
	}
}

########
# Main
########

if( $#ARGV != 1){
	print "\nUsage: regdiffexplorer pre.reg post.reg\n";
	exit 0;
}


# Display Intro and main menu
banner();

print "\nREGISTRY EXPORT (PRE): $ARGV[0] ...";
read_reg("reg1");
print "Loaded.\n";
print "REGISTRY EXPORT (POST): $ARGV[1] ...";
read_reg("reg2");
print "Loaded.\n";

# print_hash("reg1");
# identify_missing_mod();
# identify_new();

my $answer = 0;

$answer = show_menu();

# Menu Processing Loop
while ($answer != "x") {
	
	if ($answer eq "1") {
		print "\n=== Explore ALL Registry Keys (PRE & POST subkey/values) ===\n\n";
		explore_all_reg();
	}
	elsif ($answer eq "2"){
		print "\n=== Explore Modified Keys Only (PRE & POST subkey/values) ===\n\n";
		explore_mods();
		#identify_new();
	}
	elsif ($answer eq "3"){
		print "\n=== Display New Keys Only (Key:Subkey:Value) ===\n\n";
		identify_new();
	}
	elsif($answer eq "4"){
		print "\n=== Display Deleted Keys Only (Key:Subkey:Value) ===\n\n";
		identify_deleted();	
	}
	elsif ($answer eq "5"){
		print "\n=== Search Keys/Subkeys/Values with text pattern on PRE ===\n\n";
		print "TIP: Case insensitive search filter: Identity Manager^i\n";
		print "TIP: Escape backslash if included in search filter: \\CA\n\n";
		print "Enter substring to match Registry KEY [ex: Identity Manager]: ";
		my $search = <STDIN>;
		chomp $search;
		explore_reg_key_or_val_filtered_pre($search);
	}
	elsif ($answer eq "6"){
		print "\n=== Search Keys/Subkeys/Values with text pattern on POST ===\n\n";
		print "TIP: Case insensitive search filter: Identity Manager^i\n";
		print "TIP: Escape backslash if included in search filter: \\CA\n\n";
		print "Enter substring to match Registry KEY/SUBKEY/VALUE [ex: Identity Manager]: ";
		my $search = <STDIN>;
		chomp $search;
		explore_reg_key_or_val_filtered_post($search);
	}
	elsif($answer eq "7"){
		print "\n=== Export all differences to file (mod/add/rem) ===\n\n";
		print "Enter output filename with full path: ";
		my $filename = <STDIN>;
		chomp $filename;
		# Create / Overwrite to filename
		csv_missing_mod($filename);
		# Append to existing filename
		csv_new($filename);
	}elsif($answer eq "8"){
		print "\n============================== HELP ===================================\n\n";
		print "The registry diff tool can extract changes from export-1(PRE) to export-2 (POST)\n";
		print "with advanced search capabilities allowing extremely fast searches on \n";
		print "registry keys, subkeys, and values.\n\n";
		print "\n";
		print "The tool can be used for analysis of changes after software installation or upgrade\n";
		print "\nExample File Export Output:\n";
		print "[M] Key Modified: <registry key>: <subkey>: <pre value> <post value>\n";
		print "[D] Key Deleted: <registry key>: <subkey>: <key value>\n";
		print "[A] Key Added: <registry key>: <subkey>: <key value>\n";
		print "\n\n";
		print "Usage: regdiffexplorer.pl <pre-export-file> <post-export-file>\n";
		print "Example usage: regdiffexplorer.pl c:\temp\before.reg c:\temp\after.reg\n";
	}
	print "\n============= END ============= \n\n";
	$answer = show_menu();
}
