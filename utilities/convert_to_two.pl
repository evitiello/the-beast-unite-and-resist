#!/usr/bin/perl

use DBI;
use DBD::ODBC;
use strict;

my ($db_user, $db_pass)			= ('perceive_cloudmakers','cl0udmak3rs');
my $db_dsn	= "driver={SQL Server};Server=SERVERNAME;uid=$db_user;pwd=$db_pass;db=perceive_cloudmakers;";

my $dbh  = DBI->connect("dbi:ODBC:$db_dsn") or die "$DBI::err (Behind a firewall?)\n";
my $statement = $dbh->prepare("select entry_22, entry_23, username, result_size, time_reported from results order by entry_22, entry_23, username");
my $recordset = $statement->execute || die $statement->errstr;

# build up the hash with the correct rows of data in them.
my $this_row_id = 0;

my %data;

my ($old_username, $old_22, $old_23, $old_result_size);

my $counter = 0;

while (my $row = $statement->fetchrow_hashref()) {
	my $current_username				= $row->{username};
	my $current_22							= $row->{entry_22};
	my $current_23							= $row->{entry_23};
	my $current_result_size			= $row->{result_size};
	my $current_time_reported		= $row->{time_reported};
	
	if	(
				($current_username ne $old_username)
				|| ($current_result_size != $old_result_size)
			)
	{
		# start a new record if the username or result_size changes.
		$this_row_id++;
		$data{$this_row_id}{result_size}	= $current_result_size;
		$data{$this_row_id}{username}			= $current_username;
		$data{$this_row_id}{'22_start'}			= $current_22;
		$data{$this_row_id}{'23_start'}			= $current_23;
		$data{$this_row_id}{'22_end'}				= $current_22;
		$data{$this_row_id}{'23_end'}				= $current_23;
	} else {
		# otherwise update the old record with the latest end point.
		$data{$this_row_id}{'22_end'}				= $current_22;
		$data{$this_row_id}{'23_end'}				= $current_23;
		$data{$this_row_id}{time_reported}	= $current_time_reported;
	}
	
	# save a copy of all the variables 
	$old_username				= $current_username;
	$old_22							= $current_22;
	$old_23							= $current_23;
	$old_result_size		= $current_result_size;
	
	print format_counter($counter-1,$counter);
	$counter++;
}
undef $recordset;
undef $statement;

my $statement = $dbh->prepare("INSERT INTO results_2 (entry_22_start, entry_22_end, entry_23_start, entry_23_end, time_reported, username, result_size) VALUES (?,?,?,?,GETDATE(),?,?)");

open (OUTPUT, ">convert_2.txt") || die "unable to open file ($!)\n";
printf OUTPUT "%6s | %16s | %5s | %5s | %5s | %5s | %5s\n",'row','user','size','22 s','22 e','23 s','23 e';
printf OUTPUT "%6s | %16s | %5s | %5s | %5s | %5s | %5s\n",'------','----------------','-----','-----','-----','-----','-----';
foreach my $this_row (keys %data) {	
	printf OUTPUT "%6d | %16s | %5d | %5d | %5d | %5d | %5d\n",$this_row,$data{$this_row}{username},$data{$this_row}{result_size},$data{$this_row}{'22_start'},$data{$this_row}{'22_end'},$data{$this_row}{'23_start'},$data{$this_row}{'23_end'};
	$statement->execute($data{$this_row}{'22_start'},$data{$this_row}{'22_end'},$data{$this_row}{'23_start'},$data{$this_row}{'23_end'},$data{$this_row}{'username'},$data{$this_row}{'result_size'}) || die $statement->errstr;
}
close OUTPUT;

sub format_counter ($$) {
	my ($last_counter, $this_counter) = @_;
	my ($this_string, $i);
	for ($i=1; $i <= length($last_counter); $i++) {
			$this_string .= "\010";
	}
	$this_string .= $this_counter;
	return($this_string);
}
