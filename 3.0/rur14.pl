use HTTP::Request::Common;
use LWP::UserAgent;
use Config::IniFiles;
use strict;

# initialize the config file.
my $config_file = 'rur14.ini';
my $results_file = 'results.txt';
tie my %config, 'Config::IniFiles', (-file=>$config_file);

# used to stop the script.
my $stop = 0;

my $version		= '3.0';

my $UAString		= "unitecrack/$version";
my $UAEmail		= 'cloudmakers@perceive.net';

my $test_website	= "http://www.unite-and-resist.org/";
my $test_host			= "www.unite-and-resist.org";
my $test_referer	= "http://www.unite-and-resist.org/0-997B-1047-1-100-0-A.html";
my $test_post_to	= "http://www.unite-and-resist.org/responseVerify.asp";


my $update_host			= "www.perceive.net";
my $update_referer	= "http://www.perceive.net/cloudmakers";
my $update_post_to	= "http://www.perceive.net/cloudmakers/client_3.asp";

#reset some variables if theis is the development version.

my $dev = $config{main}{dev};
my $debug = $config{main}{debug};

if ($dev == 1) {
	$update_host			= "SERVERNAME";
	$update_referer	= "http://SERVERNAME/cloudmakers";
	$update_post_to	= "http://SERVERNAME/cloudmakers/client_3.asp";
}

my $connect_timeout = 60;
my $max_tries = 10;

my @dropdown = ('ANI','BLD','BLD-ANI','FLO','FLO-ANI','FLO-BLD','FLO-BLD-ANI',
						'FLO-TRE','FLO-TRE-ANI','FLO-TRE-BLD','FLO-TRE-BLD-ANI','TRE','TRE-ANI','TRE-BLD','TRE-BLD-ANI');

my $stop = 0;

sub get_page {
	my ($hex11, $hex12, $hex13, $hex21, $hex22, $hex23, $hex31, $hex32, $hex33, $pick1, $pick2, $pick3) = @_;
	
	my $ua = new LWP::UserAgent;
	$ua->agent($UAString);
	$ua->from($UAEmail);
	$ua->timeout($connect_timeout);
	if ($config{main}{proxy} =~ /^http\:/) {$ua->proxy('http', $config{main}{proxy});}

	my $this_content="formid=4&entry11=$hex11&entry12=$hex12&entry13=$hex13&entry21=$hex21&entry22=$hex22&entry23=$hex23&entry31=$hex31&entry32=$hex32&entry33=$hex33&pick1=$pick1&pick2=$pick2&pick3=$pick3&submit=Submit";

	my $request = new HTTP::Request 'POST', $test_post_to;
	$request->header('Cache-Control'		=> 'no-cache');
	$request->header('Connection' 			=> 'Keep-Alive');
	$request->header('Accept' 					=> 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*');
	$request->header('Accept-Encoding'	=> 'gzip, deflate');
	$request->header('Accept-Language'	=> 'en-us');
	$request->header('Host'							=> $test_host);
	$request->header('User-Agent'				=> $UAString);
	$request->header('Contact-Email'		=> $UAEmail);
	$request->header('Content-Length'		=> length($this_content));
	$request->header('Referer'					=> $test_referer);
	$request->header('Content-Type'			=> 'application/x-www-form-urlencoded');
	$request->content($this_content);

	print "CHECKING:\n";
	printf "  %4s %4s %4s %1s\n", $hex11, $hex12, $hex13, $pick1;
	printf "  %4s %4s %4s %1s\n", $hex21, $hex22, $hex23, $pick2;
	printf "  %4s %4s %4s %1s\n", $hex31, $hex32, $hex33, $pick3;
	print "retrieving...";

	my $response = $ua->request($request);

	my $thisfilename = "results\\${hex11}_${hex12}_${hex13}_${hex21}_${hex22}_${hex23}_${hex31}_${hex32}_${hex33}_${pick1}_${pick2}_${pick3}.html";
	if ($response->is_success) {
		return length($response->content);
	}else{
		if ($debug) { print $response->content;}
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

sub get_new_block() {
	print "***RETREIVING NEW BLOCK\n";
	my $tries = 0;
	my $this_content = "a=r&u=$config{main}{username}";
	if ($config{main}{current_block_id} ne 'NULL') {
		# this is not the first time the client was run... update the last block.
		print "CHECKING IN LAST BLOCK: $config{main}{current_block_id}\n";
		$this_content .= "&block=$config{main}{current_block_id}";
	}
	my $ua = new LWP::UserAgent;
	$ua->agent($UAString);
	$ua->from($UAEmail);
	$ua->timeout($connect_timeout);
	if ($config{main}{proxy} =~ /^http\:/) {$ua->proxy('http', $config{main}{proxy});}

	my $request = new HTTP::Request 'POST', $update_post_to;
	$request->header('Cache-Control'		=> 'no-cache');
	$request->header('Connection' 			=> 'Keep-Alive');
	$request->header('Accept' 					=> 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*');
	$request->header('Accept-Encoding'	=> 'gzip, deflate');
	$request->header('Accept-Language'	=> 'en-us');
	$request->header('Host'							=> $update_host);
	$request->header('User-Agent'				=> $UAString);
	$request->header('Contact-Email'		=> $UAEmail);
	$request->header('Content-Length'		=> length($this_content));
	$request->header('Referer'					=> $update_referer);
	$request->header('Content-Type'			=> 'application/x-www-form-urlencoded');
	$request->content($this_content);

	if ($debug) {print $request->as_string();}

	my $response = $ua->request($request);
	if ($response->is_success) {
		if ($debug) {print $response->content;}
		my @this_data = split(/\:/,$response->content);
		# setup all of the running variables.
		
		# update the begining marker of the current block
		$config{current_22}{start} = $this_data[4];
		$config{current_23}{start} = $this_data[5];
		
		$config{entry_11}{start}	= $this_data[0];
		$config{entry_12}{start}	= $this_data[1];
		$config{entry_13}{start}	= $this_data[2];
		$config{entry_21}{start}	= $this_data[3];
		$config{entry_22}{start}	= $this_data[4];
		$config{entry_23}{start}	= $this_data[5];
		$config{entry_31}{start}	= $this_data[6];
		$config{entry_32}{start}	= $this_data[7];
		$config{entry_33}{start}	= $this_data[8];

		$config{entry_11}{end}	= $this_data[9];
		$config{entry_12}{end}	= $this_data[10];
		$config{entry_13}{end}	= $this_data[11];
		$config{entry_21}{end}	= $this_data[12];
		$config{entry_22}{end}	= $this_data[13];
		$config{entry_23}{end}	= $this_data[14];
		$config{entry_31}{end}	= $this_data[15];
		$config{entry_32}{end}	= $this_data[16];
		$config{entry_33}{end}	= $this_data[17];

		$config{pick_1}{start}	= $this_data[18];
		$config{pick_2}{start}	= $this_data[19];
		$config{pick_3}{start}	= $this_data[20];

		$config{pick_1}{end}	= $this_data[21];
		$config{pick_2}{end}	= $this_data[22];
		$config{pick_3}{end}	= $this_data[23];
		
		$config{current_result}{size} = 7334;

		$config{main}{current_block_id} = $this_data[24];
		print "BLOCK $config{main}{current_block_id} CHECKED OUT.\n";
	}else{
		print "Unable to retrieve new block.  Out of blocks?";
		if ($tries <= $max_tries) {
			print "Trying again ($tries/$max_tries).\n";
			get_new_block();
		} else {
			die "giving up.";
		}
	}	
	save_config;
}

sub update_db() {
	print "***UPDATING DATABASE WITH RESULTS...\n";
	open RESULTS, "<$results_file";
	my $tries = 0;

	# HTTP based:
	while (<RESULTS>) {
		chomp;
		my @this_data = split(/\:\:/,$_);
		print "SENDING RESULT:\n";

		print  "\tblock: $this_data[5]   size: $this_data[4]\n";
		printf "\t%4x-%4x %4x-%4x\n", $this_data[0], $this_data[1], $this_data[2], $this_data[3];

		my $this_content = "a=s&u=$config{main}{username}&data=$this_data[0]:$this_data[1]:$this_data[2]:$this_data[3]:$this_data[4]:$this_data[5]";
		
		my $ua = new LWP::UserAgent;
		$ua->agent($UAString);
		$ua->from($UAEmail);
		$ua->timeout($connect_timeout);
		if ($config{main}{proxy} =~ /^http\:/) {$ua->proxy('http', $config{main}{proxy});}

		my $request = new HTTP::Request 'POST', $update_post_to;
		$request->header('Cache-Control'		=> 'no-cache');
		$request->header('Connection' 			=> 'Keep-Alive');
		$request->header('Accept' 					=> 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*');
		$request->header('Accept-Encoding'	=> 'gzip, deflate');
		$request->header('Accept-Language'	=> 'en-us');
		$request->header('Host'							=> $update_host);
		$request->header('User-Agent'				=> $UAString);
		$request->header('Contact-Email'		=> $UAEmail);
		$request->header('Content-Length'		=> length($this_content));
		$request->header('Referer'					=> $update_referer);
		$request->header('Content-Type'			=> 'application/x-www-form-urlencoded');
		$request->content($this_content);

		my $response = $ua->request($request);
		
		if ($response->is_success) {
			if ($response->content =~ /ERROR/) {
				print "ERROR OCCURRED DURING TRANSACTION\n";
				if ($debug) { print $response->content;}
				if ($tries <= $max_tries) {
					print "Trying again ($tries/$max_tries).\n";
					update_db();
				} else {
					die "giving up.";
				}
			} elsif ($response->content =~ /SUCCESS/) {
				print "BLOCK TRANSFERRED\n\n";
			} else {
				print  "UNKNOWN ERROR OCCURRED.\n";
				if ($debug) { print $response->content;}
				if ($tries <= $max_tries) {
					print "Trying again ($tries/$max_tries).\n";
					update_db();
				} else {
					die "giving up.";
				}
			}
		}else{
			print "ERROR UPDATING DATABASE.\n";
			if ($debug) { print $response->content;}
			if ($tries <= $max_tries) {
				print "Trying again ($tries/$max_tries).\n";
				update_db();
			} else {
				die "giving up.";
			}
		}
	}

	close RESULTS;
	# clean out the results file.
	open RESULTS, ">$results_file";
	print RESULTS "";
	close RESULTS;
}

sub processor {
	my ($hex11, $hex12, $hex13, $hex21, $hex22, $hex23, $hex31, $hex32, $hex33, $pick1, $pick2, $pick3, $pick1_int, $pick2_int, $pick3_int, $result_size);
	print "***PROCESSING BLOCK $config{main}{current_block_id}\n";
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
													print "\010\010\010\010\010\010\010\010\010\010\010\010\010";
													print "RESULT SIZE: $result_size\n\n";

													# write this result to the results file.
													# if this result length is NOT the same as the last one.
													
													if ($result_size != $config{current_result}{size}) {
														# first we write a result for the last chunk of blocks.
														open RESULTS, ">>$results_file";
														printf RESULTS "%d::%d::%d::%d::%d::%d\n",$config{current_22}{start},$hex22,$config{current_23}{start},$hex23,$config{current_result}{size},$config{main}{current_block_id};
														close RESULTS;
														# save the current beginning of the next result
														$config{current_23}{start} = $hex23+1;
													}
													
													$config{current_result}{size} = $result_size;
													
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
	# done with block.  finish the results file.
	open RESULTS, ">>$results_file";
	printf RESULTS "%d::%d::%d::%d::%d::%d\n",$config{current_22}{start},$hex22,$config{current_23}{start},$hex23,$config{current_result}{size},$config{main}{current_block_id};
	close RESULTS;
}

#
# RUN it all!!
#

print "$UAString\n";
print "www.perceive.net/cloudmakers/\n";
print "cloudmakers\@perceive.net\n";
print "--------------------------\n";

# check the username size.
if (length($config{main}{username}) > 16) {
	die "username too long. Please reduce to less than 16 charaters\n";
}

update_db;

if ($config{main}{current_block_id} eq 'NULL') {
	get_new_block;
	save_config;
}

while ($stop != 1) {
	processor;
	update_db;
	if ($config{main}{one_block} == 1) {
		print "Quitting after processing one block.\none_block is set on in the .ini file.\n";
		$stop=1;
	}
	get_new_block;
}
