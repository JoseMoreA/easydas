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
#This script contains the coordinates systems related functions for easyDAS

use strict;
use lib qw(./perllib);
use POSIX qw(ceil floor);
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use Data::Dumper;
use JSON;
use XML::Simple;
use SOAP::Lite;

#Basic Ontology Config. the basic parameters
my $ols_service = 'http://www.ebi.ac.uk/ontology-lookup/OntologyQuery.wsdl';
my $ontology = 'NEWT';
my $client = SOAP::Lite->service($ols_service);


my $coordinates_file = 'coordinates/registry_coordinates.xml';
my $cache_file = $coordinates_file.'.jsoncache';
my $max_days_cache = 1;

#Get the query object
my $query = new CGI;

#Get the basic parameters
my $cmd = $query->param('cmd');
my $debug = ($query->param('debug'))?1:0;

#initialize
  print $query->header(-type=>(($debug)?'text/html':'application/json'));
  my $doc_text = "";
  
if($cmd eq 'get_coordinates') {
  if((-s $cache_file) && (-M $cache_file < $max_days_cache)) {
      my $line;
      open(CACHE, "<  $cache_file");
      $doc_text .= $line while($line = <CACHE>);
      close CACHE;
  } else {

      my $coords = XMLin($coordinates_file);

      my $json = JSON->new->utf8(1);
      $doc_text = '{"coordinates": [';
      for (@{$coords->{'COORDINATES'}}) {
	$_->{'organism'} = getOrganismName($_->{'taxid'});
	$doc_text .= $json->encode($_).",";
      }
      chop($doc_text) if(substr($doc_text, -1) eq ',');
      $doc_text .= ']}';

      #save the cache
      my $cache_open = open(CACHE, ">$cache_file"); #OOOOOOOOOOOOOOOOOO No pinta!!!! >(
      if($cache_open) {print CACHE $doc_text}
      #else {print "Error!: $!\n";}
      close CACHE;
  }
} else {
  $doc_text = "{error: {id:'unknown_command', msg:'The supplied command ($cmd) is unknown'}}";
}

print $doc_text;

exit(0);

sub getOrganismName {
  my ($taxid) = @_;
  my $name;
  eval { $name = $client->getTermById($taxid, $ontology);};
#print "Result: ".Dumper($name);
  if ($@) {
    return undef; #do not die if we cannot fetch the name. It's not fundamental
  } else {
      #print "returning name: $name\n";
     return $name; 
  } 

}
