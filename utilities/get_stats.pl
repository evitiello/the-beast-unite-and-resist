#!/usr/bin/perl
use strict;
use HTTP::Request::Common;
use LWP::UserAgent;
use Net::FTP;

my $UA_version		= '1';
my $UA_name			= 'unitestats';
my $UA_email		= 'EMAILADDRESS';
my $UA_timeout		= 30;
my $mail_server		= 'SERVERNAME';
my $ebay_server		= 'cgi.ebay.com';
my $ebay_page		= '/aw-cgi/eBayISAPI.dll?MfcISAPICommand=ViewItem&item=';

my $ftp_host		= 'SERVERNAME';
my $ftp_directory	= '/d-eroot/Inetpub/wwwroot/arc/www.perceive/cloudmakers/';
my $ftp_username	= 'USERNAME';
my $ftp_password	= 'PASSWORD';

my $data_file		= 'stats_overall.htm';

my $ftp = Net::FTP->new($ftp_host);

print "$UA_name v$UA_version\n\n";


my $thisPage = "http://www.perceive.net/cloudmakers/stats_overall.asp";

# User Agent setup
#
my $ua = LWP::UserAgent->new;
$ua->agent($UA_name.'/'.$UA_version);
$ua->from($UA_email);
$ua->timeout($UA_timeout);

# send request to server and get response back
my $res = $ua->request( GET $thisPage );
if ($res->is_success) {
	my $ret_data = $res->content();
	open OUTFILE, ">$data_file";
	print OUTFILE $ret_data;
	close OUTFILE;
}

# send it all off
#
$ftp->login($ftp_username,$ftp_password);
$ftp->cwd($ftp_directory);
$ftp->ascii();

$ftp->put("$data_file");
$ftp->quit;
