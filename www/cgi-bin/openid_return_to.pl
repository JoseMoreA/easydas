#!/sw/arch/bin/perl5.8.7

#$ENV{'http_proxy'} = 'http://www-proxy.ebi.ac.uk:3128';
$ENV{'https_proxy'} = 'http://www-proxy.ebi.ac.uk:3128';

use strict;
use warnings;
use lib qw(./perllib);
use POSIX qw(ceil floor);
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use Data::Dumper;

use LWP::UserAgent;
use Net::OpenID::Consumer;


my $ua = LWP::UserAgent->new;
$ua->proxy('http', 'http://www-proxy.ebi.ac.uk:3128/'); #Set up the EBI proxy so we can access the internet

#Start
my $query = new CGI;

my $response_type = 'application/json';
print $query->header(-type=>$response_type);  #could be moved to the end if any cookie is required

my $csr = Net::OpenID::Consumer->new(
    'ua'                => $ua,
    'consumer_secret'   => "stuff", # TODO: change for a changing secet
    'args'              => $query,
    'required_root'     => "http://wwwdev.ebi.ac.uk/panda-srv/easydas/",
); #add caching

  # so you send the user off there, and then they come back to
  # openid-check.app, then you see what the identity server said.

  # Either use callback-based API (recommended)...
  $csr->handle_server_response(
      not_openid => sub {
          die "Not an OpenID message"; #FIXME: Return valid json messages for all possible responses
      },
      setup_required => sub {
          my $setup_url = shift;
	  print "SETUP";
          # Redirect the user to $setup_url
      },
      cancelled => sub {
	  print "CANCELLED";
          # Do something appropriate when the user hits "cancel" at the OP
      },
      verified => sub {
          my $vident = shift;
	  #use Data::Dumper; print "vident: ".Dumper($vident);
	  print '{"url": "'.$vident->url.'", "result": "valid"}'; 
	  #TODO: Check in and set the cookie up
	  
          # Do something with the VerifiedIdentity object $vident
      },
      error => sub {
          my $err = shift;
          die($err);
      },
  );

