#!/sw/arch/bin/perl

# easyDAS
# Copyright (C) 2008-2009 Bernat Gel 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#This script fetches the required features from an arbitrary DAS source and returns them in JSON format

#$ENV{'http_proxy'} = 'http://www-proxy.ebi.ac.uk:3128';  #Doesn't work if specified here
$ENV{'https_proxy'} = 'http://www-proxy.ebi.ac.uk:3128';  #Doesn't work if specified in teh UserAgent

use strict;
use lib qw(./perllib);
use POSIX qw(ceil floor);
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use Data::Dumper;

use JSON;
use DBI;

#User management modules
use User::Simple;
use User::Simple::Admin;

#OpenId modules
use LWP::UserAgent;
use Net::OpenID::Consumer;


#Get the query object
my $query = new CGI;

#Get the basic parameters
my $cmd = $query->param('cmd');
my $debug = ($query->param('debug'))?1:0;


#initialize
  #print (($debug)?$query->header(-type=>'text/html'):$query->header(-type=>'application/json'));
  my $doc_type =  (($debug)?'text/html':'application/json');
  my $doc_text = "";
  my $cookie = undef;
  my $openid_result = undef; #the status of the openid response (0=>valid, 1=>cancelled, 2=>setup_required, 3=>not open id, 4=>error);
  my $openid_uid = undef; #the uder identifier (url or email) for that user
  my $openid_value = undef; #an additional value to be returned by the openid functions
  
  #Begin
  my $config = &read_config;
  my $db=$config->{'DB'};
  my $dbh = DBI->connect("DBI:mysql:database=".$db->{'db'}.";host=".$db->{'host'}.":".$db->{'port'},$db->{'user'},$db->{'password'}, {RaiseError => 1, AutoCommit=>1});

  my $user_table = "Users";
  
  my $usr = User::Simple->new(db => $dbh, tbl=>$user_table);




#execute the command
if($cmd eq 'check') {
  if(&logged_in) {
    $doc_text .= qq({"loggedin": 1, "username": ").$usr->login.qq("});
  } else {
    $doc_text .= qq({"loggedin": 0});
  }
} elsif($cmd eq 'login') {
  my $login = $query->param('username');
  my $password = $query->param('password');
  
  #TODO: if no login/pass, use the ticket cookie
  $usr->ck_login($login, $password);

  if($usr->is_valid) {
    #print "Session: ".$usr->session;
    $cookie = $query->cookie(-name=>'sessionID', -value=>$usr->session);

    $doc_text .= qq({username: "$login"});
  } else {
    $doc_text .=  '{error: "invalid"}';
  }
} elsif($cmd eq 'openid_check') {
  #When a user tries to log in using openid, the IP returns som info to this page. Check if it's correct and, if so, log the user in
 
  check_openid_response();
  if($openid_result == 0) { #if the openid is valid, log the user in using 'openid' as password

    #we store the uid in the DB  with http as scheme instead of https. so change it.
    $openid_uid =~ s/https:\/\//http:\/\//gi;

    #if this is a registering petition,
    if($query->param('register')) {
      #create the new user
      my $ua = User::Simple::Admin->new($dbh, $user_table);
      my $id = $ua->new_user(login => $openid_uid, passwd => 'openid'); 
      if(!$id) {
	$doc_text = qq({"username": "$openid_uid", error: "registration_error"});
      } else {
        $usr->ck_login($openid_uid, 'openid');
      
	if($usr->is_valid) {
	    $usr->set_email($query->param('email')); #set the aditional attributes
	    $usr->set_server_name($query->param('server_name'));
	    $usr->set_is_openid(1);
	    $cookie = $query->cookie(-name=>'sessionID', -value=>$usr->session);
	    $doc_text .= qq({username: "$openid_uid"});
	} else {
	  $doc_text .=  '{error: "software error"}'; 
	}
      }
    } else { #if it's not a register petition, just login
      $usr->ck_login($openid_uid, 'openid');
      if($usr->is_valid) {
	$cookie = $query->cookie(-name=>'sessionID', -value=>$usr->session);
	$doc_text .= qq({username: "$openid_uid"});
      } else {
	$doc_text .=  '{error: "openid_unknown"}'; #the user is not in the DB. Prompt to register
      }
    }
  } elsif($openid_result != 0) {
    $doc_text .=  '{error: "openid_error"}'; #there was an error when checking the openid response. 
    #TODO: differentiate the errors and tell the user
  }
} elsif($cmd eq 'register_classic') {
  my $login = $query->param('username');
  my $password = $query->param('password');
  my $email = $query->param('email');
  my $server_name = $query->param('server_name');
  
  my $error = &uservalid($login);
  if(!$error) {
    my $ua = User::Simple::Admin->new($dbh, $user_table);
    my $id = $ua->new_user(login => $login, passwd => $password); 
    if($id) { 
      #Once the user has been created, we have to log in
      $usr->ck_login($login, $password); #log in
      if($usr->is_valid) { 
	#set its additional attributes
	$usr->set_email($email);
	$usr->set_server_name($server_name);
	#and get the session cookie
	$cookie = $query->cookie(-name=>'sessionID', -value=>$usr->session);
	$doc_text .=  qq({"username": "$login"});
      } else {
	$doc_text .=  qq({"username": "$login", error: "registration_error"});	
      }
    } else {
      $doc_text .=  qq({"username": "$login", error: "registration_error"});
    }
  }
} elsif($cmd eq 'check_username') {
  my $login = $query->param('username');
  my $error = &uservalid($login);
  if(!$error) {
    $doc_text .=  qq({"username": "$login", valid: 1});
  } else {
    $doc_text .=  qq({"username": "$login", valid: 0, error: "$error"});
  }
} elsif($cmd eq 'logout') {
  if(&logged_in) {
    #The user is logged in
    my $ok = $usr->end_session;
    $doc_text .= ($ok)?'{"loggedout": 1}':'{"loggedout": 0, "error": "db_error"}';
  } else {
    $doc_text .= '{"loggedout": 1, "error": "not_loggedin"}';
  }
  #remove the cookie
  $cookie = $query->cookie(-name=>'sessionID', -value=>'', -expires=>'-1h');
} elsif($cmd eq 'check_server_name') {
  #Check if the server name is valid and if its available (not in use by someone else)
  my $sn = $query->param('server_name');
  my $error = valid_server_name($sn);
  if(!$error) {
    $doc_text .=  qq({"server_name": "$sn", valid: 1});
  } else {
    $doc_text .=  qq({"server_name": "$sn", valid: 0, error: "$error"});
  }
} 

if($cookie) {
  print $query->header(-type=>$doc_type, -cookie=>$cookie);  
} else {
  print $query->header(-type=>$doc_type);  
}

print $doc_text;

exit(0);

sub uservalid {
  my $username = shift;
  
  #TODO: Check for invalid chars

  if($username eq 'anonymous') {
    return 'invalid_name';
  }

  my $unique_user = $dbh->prepare_cached("SELECT COUNT(*) FROM `easydas`.`$user_table` WHERE `login` = ?");
  $unique_user->execute($username);
  my @res = $unique_user->fetchrow_array();
  if($unique_user->err()) {
    return 'db_error';
  } elsif(@res[0] > 0) {
    return 'duplicate_username';
  }
  return '';
}

sub logged_in {
  my $session = $query->cookie('sessionID');
  return (($session and $usr->ck_session($session))?1:0);
    
}

sub read_config {
  open (CONF, "< ./config.pl") || die "<h1> Can't Open config.json to read the config</h1>";
  my @lines = <CONF>;
  my $lines = join("", @lines);
  my $config = JSON->new->decode($lines);

  return $config;
}
 
#return true iif the user has registered using openid
sub is_openid {
  my ($login) = @_;
  
  my $user = $dbh->prepare("SELECT is_openid FROM `easydas`.`$user_table` WHERE `login` = ?");
  $user->execute($login);
  my @res = $user->fetchrow_array();
  if($user->err()) {
    $user->finish();
    return 'db_error';
  } else {
    $user->finish();
    return @res[0];
  }
  return 0;
}

sub valid_server_name {
  my ($sn) = @_;
#   $doc_text .= "Server_ame: $sn";
  if($sn !~ /^[a-zA-Z-_123456789]+$/) {
    return "invalid characters used";
  } else {
    my $user = $dbh->prepare("SELECT COUNT(*) FROM `easydas`.`$user_table` WHERE `server_name` = ?");
    $user->execute($sn);
    my @res = $user->fetchrow_array();
    if($user->err()) {
      return 'db_error';
    } elsif(@res[0] > 0) {
      return "server_name already in use";
    } 
    return 0;
  }
  return "software error";
}

sub check_openid_response {

  my $ua = LWP::UserAgent->new;
  $ua->proxy('http', 'http://www-proxy.ebi.ac.uk:3128/'); #Set up the EBI proxy so we can access the internet (this one doesn't work if set-up using $ENV)


  my $csr = Net::OpenID::Consumer->new(
      'ua'                => $ua,
      'consumer_secret'   => "stuff", # TODO: change for a changing secet
      'args'              => $query,
      'required_root'     => "http://wwwdev.ebi.ac.uk/panda-srv/easydas/",
  ); #add caching

  #check if the response was valid
  $csr->handle_server_response(
      not_openid => sub {
          $openid_result = 3;
      },
      setup_required => sub {
          my $setup_url = shift;
	  $openid_result=2;
          $openid_value=$setup_url;
      },
      cancelled => sub {
          $openid_result=1;
      },
      verified => sub {
          my $vident = shift;
	  #use Data::Dumper; print "vident: ".Dumper($vident);
	  $openid_uid = $vident->url;
	  $openid_result=0;
      },
      error => sub {
          my $err = shift;
	  $openid_result = 4;
          $openid_value = $err;
      },
  );


}
