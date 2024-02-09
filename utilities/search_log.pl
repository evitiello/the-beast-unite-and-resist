open INFILE, "<today.log";
open OUTFILE, ">outlog.txt";

while (<INFILE>) {
	if ($_ =~ /64\.166\./) {
		print OUTFILE $_;
	}
}

close OUTFILE;
close INFILE;