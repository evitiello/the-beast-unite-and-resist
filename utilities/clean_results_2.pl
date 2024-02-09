#!/usr/bin/perl

use DBI;
use DBD::ODBC;
use strict;

my ($db_user, $db_pass)			= ('perceive_cloudmakers','cl0udmak3rs');
my $db_dsn	= "driver={SQL Server};Server=SERVERNAME;uid=$db_user;pwd=$db_pass;db=perceive_cloudmakers;";

my $counter=0;

sub clean_blocks() {
	open CLEAN, ">cleaned_blocks.sql";
	my $dbh  = DBI->connect("dbi:ODBC:$db_dsn") or die "$DBI::err (Behind a firewall?)\n";
	my $statement = $dbh->prepare("select * from results where result_size=0");
	my $recordset = $statement->execute || die $statement->errstr;
	while (my $row = $statement->fetchrow_hashref()) {
my $sql = <<END;

INSERT INTO blocks (
	entry_11_start, entry_11_end, entry_12_start,	entry_12_end, entry_13_start,	entry_13_end, entry_21_start,	entry_21_end,
	entry_22_start,	entry_22_end, entry_23_start,	entry_23_end,
	entry_31_start,	entry_31_end,	entry_32_start,	entry_32_end,	entry_33_start,	entry_33_end,
	pick_1_start,	pick_1_end,	pick_2_start,	pick_2_end,	pick_3_start,	pick_3_end
) VALUES (
	65535,65535,45007,45007,61695,61695,65535,65535,
	$row->{entry_22},$row->{entry_22},$row->{entry_23},$row->{entry_23},
	64575,64575,65535,65535,43690,43690,12,12,9,9,13,13
)
END

	my $sql_2 = "DELETE results WHERE entry_22=$row->{entry_22} AND entry_23=$row->{entry_23}";

	my $dbh_2  = DBI->connect("dbi:ODBC:$db_dsn") or die "$DBI::err (Behind a firewall?)\n";
	my $statement_2 = $dbh_2->prepare($sql);
	$statement_2->execute || die $statement_2->errstr;
	
	undef $statement_2;
	
	my $statement_2 = $dbh_2->prepare($sql_2);
	$statement_2->execute || die $statement_2	->errstr;
	
	undef $statement_2;

	$counter++;

	print format_counter($counter-1,$counter);

	}	
}

sub format_counter ($$) {
	my ($last_counter, $this_counter) = @_;
	my ($this_string, $i);
	for ($i=1; $i <= length($last_counter); $i++) {
			$this_string .= "\010";
	}
	$this_string .= $this_counter;
	return($this_string);
}


clean_blocks;