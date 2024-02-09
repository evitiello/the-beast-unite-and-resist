use HTTP::Request::Common;
use HTTP::Headers;
use LWP::UserAgent;
use Net::SMTP;

$UAString		= 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)';
#$UAString		= 'unitecrack/1.0';
$UAEmail		= 'eric@perceive.net';


$website = "http://www.unite-and-resist.org/";
$referer = "http://www.unite-and-resist.org/0-997B-1047-1-100-0-A.html";
$post_to = "http://www.unite-and-resist.org/responseVerify.asp";

@dropdown = ('ANI','BLD','BLD-ANI','FLO','FLO-ANI','FLO-BLD','FLO-BLD-ANI',
						'FLO-TRE','FLO-TRE-ANI','FLO-TRE-BLD','FLO-TRE-BLD-ANI','TRE','TRE-ANI','TRE-BLD','TRE-BLD-ANI');

#POST http://www.unite-and-resist.org/responseVerify.asp
#referer: http://www.unite-and-resist.org/0-997B-1047-1-100-0-A.html
#entry11=0000&entry12=0000&entry13=0000&entry21=0000&entry22=0000&entry23=0000&entry31=0000&entry32=0000&entry33=0000&pick1=ANI&pick2=ANI&pick3=ANI

sub LOGIC_getPage {
	my ($hex11, $hex12, $hex13, $hex21, $hex22, $hex23, $hex31, $hex32, $hex33, $pick1, $pick2, $pick3) = @_;
	
	$h = new HTTP::Headers
			Referer => $referer;
	
	$ua = new LWP::UserAgent;
	$ua->agent($UAString);
	$ua->from($UAEmail);
	$ua->timeout(30);

	$HTTPrequest = $ua->request(POST, $post_to, $h,
		[
			entry11	=> $hex11,
			entry12	=>$hex12,
			entry13	=>$hex13,
			entry21	=>$hex21,
			entry22	=>$hex22,
			entry23	=>$hex23,
			entry31	=>$hex31,
			entry32	=>$hex32,
			entry33	=>$hex33,
			pick1		=>$pick1,
			pick2		=>$pick2,
			pick3		=>$pick3
		]
	);
	
	my $thisfilename = "$hex11_$hex12_$hex13_$hex21_$hex22_$hex23_$hex31_$hex32_$hex33_$pick1_$pick2_$pick3.html";
	open(THISFILE,">$thisfilename");
	if ($HTTPrequest->is_success) {
		print THISFILE $HTTPrequest->content;
	}else{
		if ($HTTPrequest->is_redirect) {
			print THISFILE "REDIRECT ",$HTTPrequest->error_as_HTML;
		} else {
			print THISFILE $HTTPrequest->error_as_HTML;
		}
	}
	close THISFILE;
}

sub convert_hex($) {
	($this_value) = @_;
	$this_value = sprintf("%lx",$this_value);
	#while (length($this_value) <= 4) {
	#	$this_value = "$this_value0";
	#}
}

for ($hex11=0; $hex11 < 65535; $hex11++) {
	for ($hex12=0; $hex12 < 65535; $hex12++) {
		for ($hex13=0; $hex13 < 65535; $hex13++) {
			foreach my $pick1 (@dropdown) {
				for ($hex21=0; $hex21 < 65535; $hex21++) {
					for ($hex22=0; $hex22 < 65535; $hex22++) {
						for ($hex23=0; $hex23 < 65535; $hex23++) {
							foreach my $pick2 (@dropdown) {
								for ($hex31=0; $hex31 < 65535; $hex31++) {
									for ($hex32=0; $hex32 < 65535; $hex32++) {
										for ($hex33=0; $hex33 < 65535; $hex33++) {
											foreach my $pick3 (@dropdown) {
												LOGIC_getPage convert_hex($hex11), convert_hex($hex12), convert_hex($hex13), convert_hex($hex21), convert_hex($hex22), convert_hex($hex23), convert_hex($hex31), convert_hex($hex32), convert_hex($hex33), $pick1, $pick2, $pick3;
												#print sprintf("%lx",$hex11)." : ".sprintf("%lx",$hex12)." : ".sprintf("%lx",$hex13)." : $pick1\n";
												#print sprintf("%lx",$hex21)." : ".sprintf("%lx",$hex22)." : ".sprintf("%lx",$hex23)." : $pick2\n";
												#print sprintf("%lx",$hex31)." : ".sprintf("%lx",$hex32)." : ".sprintf("%lx",$hex33)." : $pick3\n";
												#print "\n";
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