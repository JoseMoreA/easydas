#!/sw/arch/bin/perl5.8.7

##!/usr/bin/perl

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

use strict;
use lib qw(./perllib);
use POSIX qw(ceil floor);
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use Data::Dumper;
use File::Temp;
use easyDAS::FileMetadata;
use easyDAS::Controller;

use User::Simple;

#CONSTANTS 
#TODO: USe some kind of external config file
my $tmpdir = "./tmpFiles";
my $DAS_SERVER_HOSTNAME;
my $DAS_SERVER_PORT;

#INITIALIZATION
$File::Temp::KEEP_ALL = 1; #Tell File Temp that we do not want it to automatically delete the temporary files

#Start
my $query = new CGI;

#Get the command
my $cmd = $query->param('cmd');
my $metadata = $query->param('metadata');
my $debug = ($query->param('debug'))?1:0;

  #Begin
  my $config = &read_config;
  my $db=$config->{'DB'};
  my $dbh = DBI->connect("DBI:mysql:database=".$db->{'db'}.";host=".$db->{'host'}.":".$db->{'port'},$db->{'user'},$db->{'password'}, {RaiseError => 1, AutoCommit=>1});

  my $user_table = "Users";
  
  my $usr = User::Simple->new(db => $dbh, tbl=>$user_table);

  $DAS_SERVER_HOSTNAME = $config->{'DAS_server'}->{'hostname'};
  $DAS_SERVER_PORT = $config->{'DAS_server'}->{'port'};

#Check for session
my $username = &check_session;
print "The username is: $username\n"  if($debug);

#upload a file, process it and return it's information
if($cmd eq "upload") { #Upload a file

  #get the file format info from the user
  my $file_format = $query->param('file_format');

  #print $query->header(-type=>'application/json') unless($debug);
  print $query->header(-type=>'text/html'); # if($debug);  #Although we are returning JSON, we need to set the header to html since we will be using iframe-based communication

  #Check if the file is present
  my $file = $query->param('datafile');
  if(!$file) {
    print $query->header(-type=>'text/html');
    die '{"error": true, "error_info": {id: "no_uploaded_file", msg: "The uploaded file was not found. Maybe there was a network error. Please check your form and try again"}}';
  }

 
  #Get a new file Id
  my $fh = File::Temp->new(DIR=>$tmpdir);
  my $fname = $fh->filename;

  my $name = (scalar $file).""; #Hack: Add the empty "" at the end so name is actually only the scalar value "name" and not the ful blessed Fh

  while(<$file>) {
    print $fh $_;
  }
  close $fh;

  if($debug) {
    print qq(original filename: $name\n);
    print qq(temporary filename: $fname\n);
    print qq(fileformat: $file_format\n);
  }

  #get the metadata for that file
  my $meta = easyDAS::FileMetadata->new({original_filename=>$name, file_id=>$fname, temp_dir=>$tmpdir, debug=>$debug, username=>$username});
  
  #Launch fileTest in order to get all the information about the file
  my $controller = easyDAS::Controller->new($debug); #create the controller
  if($file_format ne 'automatic') {
    $meta->{'forced_parser_type'} = $file_format;
  }
  $meta = $controller->test($meta);  #and call the testing function
  
  #Return the results and save them to a file
  print $meta->toJSON();


#} elsif($cmd eq 'retest') {
} elsif($cmd eq 'retest' || $cmd eq 'create_source') {
   
   print (($debug)?$query->header(-type=>'text/html'):$query->header(-type=>'application/json'));
   my $meta = easyDAS::FileMetadata->newFromString($metadata);
   my $controller = easyDAS::Controller->new($debug); 
  
   $meta = $controller->$cmd($meta);  #and call the retest/creation function
 
   my $strmeta =  $meta->toJSON();
   $strmeta = substitute($strmeta);
   print $strmeta;
 
} else {
  if($debug) {
    print $query->header(-type=>'text/html');
    print "<p>Unknown command: $cmd";
  } else {
    print $query->header(-type=>'application/json');
    print "{error: {type: \"UnknownCommand\", \"message\": \"Unknown Command: $cmd\"}}";
  }
}

exit(0);

#Substitutes some key text with runtime values
# currently {DASHOST} by the name of the host we are
sub substitute {
  my ($str) = @_;

  my $das_hostname = $DAS_SERVER_HOSTNAME || $ENV{'SERVER_NAME'};
  my $das_host = $das_hostname.($DAS_SERVER_PORT?':'.$DAS_SERVER_PORT:'');
  $str =~ s/{DASHOST}/$das_host/g;
  
  return $str;
}

sub check_session {
  my $session = $query->cookie('sessionID');
  if($session and $usr->ck_session($session)) {
    #The user is logged in
    return $usr->login;
  } else {
    return 'anonymous';
  }
}

sub read_config {
  open (CONF, "< ./config.pl") || die "<h1> Can't Open config.json to read the config</h1>";
  my @lines = <CONF>;
  my $lines = join("", @lines);
  my $config = JSON->new->decode($lines);

  return $config;
}
 
