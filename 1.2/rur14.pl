use HTTP::Request::Common;
use LWP::UserAgent;
use Config::IniFiles;
use DBI;
use DBD::ODBC;
use strict;

#$UAString		= 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)';

my $version		= '1.2';

my $UAString		= "unitecrack/$version";
my $UAEmail		= 'cloudmakers@perceive.net';

my ($db_user, $db_pass)			= ('perceive_cloudmakers','3van1sD3ad');
my $db_dsn	= "driver={SQL Server};Server=www.perceive.net;uid=$db_user;pwd=$db_pass;db=perceive_cloudmakers;";

my $website = "http://www.unite-and-resist.org/";
my $referer = "http://www.unite-and-resist.org/0-997B-1047-1-100-0-A.html";
my $post_to = "http://www.unite-and-resist.org/responseVerify.asp";

my @dropdown = ('ANI','BLD','BLD-ANI','FLO','FLO-ANI','FLO-BLD','FLO-BLD-ANI',
						'FLO-TRE','FLO-TRE-ANI','FLO-TRE-BLD','FLO-TRE-BLD-ANI','TRE','TRE-ANI','TRE-BLD','TRE-BLD-ANI');

my $config_file = 'rur14.ini';
my $results_file = 'results.txt';
tie my %config, 'Config::IniFiles', (-file=>$config_file);

my $stop = 0;

sub get_page {
	my ($hex11, $hex12, $hex13, $hex21, $hex22, $hex23, $hex31, $hex32, $hex33, $pick1, $pick2, $pick3) = @_;
	
	my $ua = new LWP::UserAgent;
	$ua->agent($UAString);
	$ua->from($UAEmail);
	$ua->timeout(30);

	my $this_content="formid=4&entry11=$hex11&entry12=$hex12&entry13=$hex13&entry21=$hex21&entry22=$hex22&entry23=$hex23&entry31=$hex31&entry32=$hex32&entry33=$hex33&pick1=$pick1&pick2=$pick2&pick3=$pick3&submit=Submit";

	my $request = new HTTP::Request 'POST', $post_to;
	$request->header('Cache-Control'		=> 'no-cache');
	$request->header('Connection' 			=> 'Keep-Alive');
	$request->header('Accept' 					=> 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*');
	$request->header('Accept-Encoding'	=> 'gzip, deflate');
	$request->header('Accept-Language'	=> 'en-us');
	$request->header('Host'							=> 'www.unite-and-resist.org');
	$request->header('User-Agent'				=> $UAString);
	$request->header('Contact-Email'		=> $UAEmail);
	$request->header('Content-Length'		=> length($this_content));
	$request->header('Referer'					=> $referer);
	$request->header('Content-Type'			=> 'application/x-www-form-urlencoded');
	$request->content($this_content);

	print "CHECKING:\n";
	printf "%4s %4s %4s %1s\n", $hex11, $hex12, $hex13, $pick1;
	printf "%4s %4s %4s %1s\n", $hex21, $hex22, $hex23, $pick2;
	printf "%4s %4s %4s %1s\n", $hex31, $hex32, $hex33, $pick3;

	#print $request->as_string(); 
	my $response = $ua->request($request);

	my $thisfilename = "results\\${hex11}_${hex12}_${hex13}_${hex21}_${hex22}_${hex23}_${hex31}_${hex32}_${hex33}_${pick1}_${pick2}_${pick3}.html";
	if ($response->is_success) {
		return length($response->content);
		#print THISFILE $response->content;
		#open(THISFILE,">$thisfilename");
		#close THISFILE;
	}else{
		return 0;
	}
}

sub convert_hex($) {
	my ($this_value) = @_;
	return sprintf("%lx",$this_value);
}

sub save_config {
	tied( %config )->RewriteConfig || die "Could not write settings to file.";
}

sub get_new_block {
	print "RETREIVING NEW BLOCK\n";
	my $dbh  = DBI->connect("dbi:ODBC:$db_dsn") or die "$DBI::err (Behind a firewall?)\n";
	if ($config{main}{current_block_id} ne 'NULL') {
		# this is not the first time the client was run... update the last block.
		print "CHECKING IN LAST BLOCK: $config{main}{current_block_id}\n";
		my $statement = $dbh->prepare("UPDATE blocks SET time_checked_in = GETDATE() WHERE block_id = $config{main}{current_block_id}");
		$statement->execute || die $statement->errstr;	
	}
	# get a new block.
	my $statement = $dbh->prepare("sp_get_new_block '$config{main}{username}'");
	my $recordset = $statement->execute || die $statement->errstr;
	my $rowcount = 0;
	while (my $row = $statement->fetchrow_hashref()) {
		# setup all of the running variables.
		$config{entry_11}{start}	= $row->{entry_11_start};
		$config{entry_12}{start}	= $row->{entry_12_start};
		$config{entry_13}{start}	= $row->{entry_13_start};
		$config{entry_21}{start}	= $row->{entry_21_start};
		$config{entry_22}{start}	= $row->{entry_22_start};
		$config{entry_23}{start}	= $row->{entry_23_start};
		$config{entry_31}{start}	= $row->{entry_31_start};
		$config{entry_32}{start}	= $row->{entry_32_start};
		$config{entry_33}{start}	= $row->{entry_33_start};

		$config{entry_11}{end}	= $row->{entry_11_end};
		$config{entry_12}{end}	= $row->{entry_12_end};
		$config{entry_13}{end}	= $row->{entry_13_end};
		$config{entry_21}{end}	= $row->{entry_21_end};
		$config{entry_22}{end}	= $row->{entry_22_end};
		$config{entry_23}{end}	= $row->{entry_23_end};
		$config{entry_31}{end}	= $row->{entry_31_end};
		$config{entry_32}{end}	= $row->{entry_32_end};
		$config{entry_33}{end}	= $row->{entry_33_end};

		$config{pick_1}{start}	= $row->{pick_1_start};
		$config{pick_2}{start}	= $row->{pick_2_start};
		$config{pick_3}{start}	= $row->{pick_3_start};
		
		$config{pick_1}{end}	= $row->{pick_1_end};
		$config{pick_2}{end}	= $row->{pick_2_end};
		$config{pick_3}{end}	= $row->{pick_3_end};
		
		$config{main}{current_block_id} = $row->{block_id};
		$rowcount++;
		
		print "BLOCK $config{main}{current_block_id} CHECKED OUT.\n";
	}
	if ($rowcount == 0) {
		die "Unable to retrieve new block.  Out of blocks?\n";
	}
	save_config;
}

sub update_db() {
	print "UPDATING DATABASE WITH RESULTS...\n";
	open RESULTS, "<$results_file";
	my $dbh  = DBI->connect("dbi:ODBC:$db_dsn") or die "$DBI::err (Behind a firewall?)\n";
	while (<RESULTS>) {
		chomp;
		my @this_data = split(/\:\:/,$_);
		print "SENDING RESULT ($this_data[12]):\n";
		printf "%4x %4x %4x %1s\n", $this_data[0], $this_data[1], $this_data[2], $dropdown[$this_data[3]];
		printf "%4x %4x %4x %1s\n", $this_data[4], $this_data[5], $this_data[6], $dropdown[$this_data[7]];
		printf "%4x %4x %4x %1s\n\n", $this_data[8], $this_data[9], $this_data[10], $dropdown[$this_data[11]];
		my $statement = $dbh->prepare("INSERT INTO results (entry_11,entry_12,entry_13,pick_1,entry_21,entry_22,entry_23,pick_2,entry_31,entry_32,entry_33,pick_3,result_size,time_reported,username) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,GETDATE(),'$config{main}{username}')");
		my $recordset = $statement->execute(@this_data) || die $statement->errstr;
	}
	
	close RESULTS;
	# clean out the results file.
	open RESULTS, ">$results_file";
	print RESULTS "";
	close RESULTS;
}

sub processor {
	my ($hex11, $hex12, $hex13, $hex21, $hex22, $hex23, $hex31, $hex32, $hex33, $pick1, $pick2, $pick3, $pick1_int, $pick2_int, $pick3_int);
	print "PROCESSING BLOCK $config{main}{current_block_id}\n";
	for ($hex11=$config{entry_11}{start}; $hex11 <= $config{entry_11}{end}; $hex11++) {
		for ($hex12=$config{entry_12}{start}; $hex12 <= $config{entry_12}{end}; $hex12++) {
			for ($hex13=$config{entry_13}{start}; $hex13 <= $config{entry_13}{end}; $hex13++) {
				for ($pick1_int=$config{pick_1}{start}; $pick1_int <= $config{pick_1}{end}; $pick1_int++) {
					$pick1 = $dropdown[$pick1_int];
					for ($hex21=$config{entry_21}{start}; $hex21 <= $config{entry_21}{end}; $hex21++) {
						for ($hex22=$config{entry_22}{start}; $hex22 <= $config{entry_22}{end}; $hex22++) {
							for ($hex23=$config{entry_23}{start}; $hex23 <= $config{entry_23}{end}; $hex23++) {
								for ($pick2_int=$config{pick_2}{start}; $pick2_int <= $config{pick_2}{end}; $pick2_int++) {
									$pick2 = $dropdown[$pick2_int];
									for ($hex31=$config{entry_31}{start}; $hex31 <= $config{entry_31}{end}; $hex31++) {
										for ($hex32=$config{entry_32}{start}; $hex32 <= $config{entry_32}{end}; $hex32++) {
											for ($hex33=$config{entry_33}{start}; $hex33 <= $config{entry_33}{end}; $hex33++) {
												for ($pick3_int=$config{pick_3}{start}; $pick3_int <= $config{pick_3}{end}; $pick3_int++) {
													$pick3 = $dropdown[$pick3_int];

													my $result_size = get_page convert_hex($hex11), convert_hex($hex12), convert_hex($hex13), convert_hex($hex21), convert_hex($hex22), convert_hex($hex23), convert_hex($hex31), convert_hex($hex32), convert_hex($hex33), $pick1, $pick2, $pick3;
													print "RESULT SIZE: $result_size\n\n";

													#print sprintf("%lx",$hex11)." : ".sprintf("%lx",$hex12)." : ".sprintf("%lx",$hex13)." : $pick1\n";
													#print sprintf("%lx",$hex21)." : ".sprintf("%lx",$hex22)." : ".sprintf("%lx",$hex23)." : $pick2\n";
													#print sprintf("%lx",$hex31)." : ".sprintf("%lx",$hex32)." : ".sprintf("%lx",$hex33)." : $pick3\n";
													#print "\n";

													# write this result to the results file.
													open RESULTS, ">>$results_file";
													printf RESULTS "%d::%d::%d::%d::%d::%d::%d::%d::%d::%d::%d::%d::%d\n",$hex11,$hex12,$hex13,$pick1_int,$hex21,$hex22,$hex23,$pick2_int,$hex31,$hex32,$hex33,$pick3_int,$result_size;
													close RESULTS;
													
													# save off the current position.
													$config{entry_11}{start}		=$hex11;
													$config{entry_12}{start}		=$hex12;
													$config{entry_13}{start}		=$hex13;
													$config{pick_1}{start}			=$pick1_int;
													$config{entry_21}{start}		=$hex21;
													$config{entry_22}{start}		=$hex22;
													$config{entry_23}{start}		=$hex23;
													$config{pick_2}{start}			=$pick2_int;
													$config{entry_31}{start}		=$hex31;
													$config{entry_32}{start}		=$hex32;
													$config{entry_33}{start}		=$hex33;
													$config{pick_3}{start}			=$pick3_int;
													save_config;
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	update_db;
	get_new_block;
}

#
# RUN it all!!
#

print "$UAString\n";
print "www.perceive.net/cloudmakers/\n";
print "cloudmakers\@perceive.net\n";
print "--------------------------\n";

update_db;

if ($config{main}{current_block_id} eq 'NULL') {
	get_new_block;
}

while ($stop != 1) {
	processor;
}