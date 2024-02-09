#!/usr/bin/perl

use DBI;
use DBD::ODBC;
use strict;

my ($db_user, $db_pass)			= ('perceive_cloudmakers','cl0udmak3rs');
my $db_dsn	= "driver={SQL Server};Server=SERVERNAME;uid=$db_user;pwd=$db_pass;db=perceive_cloudmakers;";

my $counter=0;

sub remove_duplicates() {
	my $dbh  = DBI->connect("dbi:ODBC:$db_dsn") or die "$DBI::err (Behind a firewall?)\n";
	my $statement = $dbh->prepare("select entry_22, entry_23, count(*) As Total from results group by entry_22, entry_23 having count(*)>1");
	my $recordset = $statement->execute || die $statement->errstr;
	while (my $row = $statement->fetchrow_hashref()) {

		print "22: $row->{entry_22} 23: $row->{entry_23}\n";
		
		my $good_row_id;
		
		my $sql_2 = "select top 1 result_id, result_size from results where entry_22=$row->{entry_22} and entry_23=$row->{entry_23} order by result_size DESC, result_id";
		my $dbh_2  = DBI->connect("dbi:ODBC:$db_dsn") or die "$DBI::err (Behind a firewall?)\n";
		my $statement_2 = $dbh_2->prepare($sql_2);
		my $recordset_2 = $statement_2->execute || die $statement_2->errstr;
		while (my $row_2 = $statement_2->fetchrow_hashref()) {
			$good_row_id = $row_2->{result_id};
			print "good: $good_row_id\n";
		}
		
		# kill off all the dups.
		my $sql_3 = "delete results where entry_22=$row->{entry_22} and entry_23=$row->{entry_23} and result_id != $good_row_id";
		my $dbh_3  = DBI->connect("dbi:ODBC:$db_dsn") or die "$DBI::err (Behind a firewall?)\n";
		my $statement_3 = $dbh_3->prepare($sql_3);
		$statement_3->execute || die $statement_3->errstr;
		
		
		undef $dbh_3;
		undef $dbh_2;
	}	
}


remove_duplicates;