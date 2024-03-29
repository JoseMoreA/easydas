#!/usr/local/bin/perl
#########
# Author:        rmp
# Maintainer:    $Author: andyjenkinson $
# Created:       2003-05-22
# Last Modified: $Date: 2008-09-21 20:05:54 +0100 (Sun, 21 Sep 2008) $
# Source:        $Source $
# Id:            $Id $
#
# ProServer DAS Server CGI handler
#
# loading and processing the proserver.ini can have high overheads
# so, as is, this might be best run inside FastCGI
#
package proserver;
use lib qw(../blib/lib ../lib);
use Bio::Das::ProServer;
use strict;
use warnings;
use Carp;

our $VERSION = do { my ($v) = (q$Revision: 528 $ =~ /\d+/mxg); $v; };

main();
0;

sub main {
  if(!$ENV{'PROSERVER_CFG'}) {
    croak q(No PROSERVER_CFG configured in environment);
  }

  my ($cfgfile) = $ENV{'PROSERVER_CFG'} =~ m|([/_a-z\d\.\-]+)|mix;
  $cfgfile    ||= q();

  if($cfgfile ne $ENV{'PROSERVER_CFG'}) {
    croak "PROSERVER_CFG failed to detaint ($cfgfile)\n";
  }

  my $config   = Bio::Das::ProServer::Config->new({'inifile' => $cfgfile,});
  my $heap     = {'method' => 'cgi','self' => {'config' => $config,'logformat'=>$config->logformat()},};
  my $request  = HTTP::Request->new( 'GET', $ENV{'REQUEST_URI'}||q() );
  my $response = Bio::Das::ProServer::build_das_response($heap, $request);

  print $response->headers->as_string, "\n", $response->content();
  return;
}
