#  HTTP test DAEMON
#
#
#


use HTTP::Daemon;
use HTTP::Status;
my $d = new HTTP::Daemon(LocalPort=>8080);
print "Please contact me at: <URL:", $d->url, ">\n";
while (my $c = $d->accept) {
		while (my $r = $c->get_request) {
				if ($r->method eq 'GET' and $r->url->path eq "/stuff/") {
						# remember, this is *not* recommened practice :-)
						$c->send_file_response("0-997B-1047-1-100-0-A.htm");
				} else {
						$c->send_error(RC_FORBIDDEN)
				}
				print "REQUEST MADE\n";
				print $r->as_string();

				#$c->send_error(RC_FORBIDDEN);
				
				#$c->send_file("0-997B-1047-1-100-0-A.htm");
		}
		$c->close;
		undef($c);
}
