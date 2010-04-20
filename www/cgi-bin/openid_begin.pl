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
my $uid = $query->param('uid');

#params only used when registering
my $cmd = $query->param('cmd');
my $email = $query->param('email');
my $server_name = $query->param('server_name');


my $csr = Net::OpenID::Consumer->new(
    'ua'                => $ua,
    'consumer_secret'   => "stuff",
    'args'              => $query,
    'required_root'     => "http://wwwdev.ebi.ac.uk/panda-srv/easydas/",
);


  

my $claimed_identity = $csr->claimed_identity($uid) #"http://bernatgel.myopenid.com") #https://www.google.com/accounts/o8/id")
    or die $csr->err;



  my $return_adr = "http://wwwdev.ebi.ac.uk/panda-srv/easydas/popup_return_to.html";
  if($cmd eq "register") {
    $return_adr .= "?register=1&email=$email&server_name=$server_name";
  }


  my $check_url = $claimed_identity->check_url(
    return_to  => $return_adr,
    trust_root => "http://wwwdev.ebi.ac.uk/panda-srv/easydas/",
    delayed_return  => 1
  );

  print $query->redirect($check_url); 
  








  # so you send the user off there, and then they come back to
  # openid-check.app, then you see what the identity server said.

  # Either use callback-based API (recommended)...
#   $csr->handle_server_response(
#       not_openid => sub {
#           die "Not an OpenID message";
#       },
#       setup_required => sub {
#           my $setup_url = shift;
# 	  print "SETUP";
#           # Redirect the user to $setup_url
#       },
#       cancelled => sub {
# 	  print "CANCELLED";
#           # Do something appropriate when the user hits "cancel" at the OP
#       },
#       verified => sub {
#           my $vident = shift;
# 	  print "VALID";
#           # Do something with the VerifiedIdentity object $vident
#       },
#       error => sub {
#           my $err = shift;
#           die($err);
#       },
#   );

