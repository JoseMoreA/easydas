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
#This script forwards the call to the given URL and returns its response. Used to overcome the SOP

use strict;
use lib qw(./perllib);
use POSIX qw(ceil floor);
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use SOAP::Lite;
use Data::Dumper;

#Basic Config the basic parameters
#my $ols = 'http://www.ebi.ac.uk/ontology-lookup/services/OntologyQuery';
my $ols_service = 'http://www.ebi.ac.uk/ontology-lookup/OntologyQuery.wsdl';
my $default_ontology = 'SO';

#Get the query object
my $query = new CGI;


my $cmd = $query->param('cmd');
my $ontology = $query->param('ont') || $default_ontology;
my $debug = ($query->param('debug'))?1:0;

my $response_type = ($debug)?'text/html':'application/json';
print $query->header(-type=>$response_type);  #could be moved to the end if any cookie is required

my $client = SOAP::Lite->service($ols_service);
my $response="";
my $result;
if($cmd eq 'roots') {
  eval { $result = $client->getRootTerms($ontology); };
  if ($@) {
    $response = qq({error: {id: 'webservice_error', msg: 'There was an error when calling the Ontology Lookup Service webservice' extended_msg: $@});
  } else {
    $response = qq({);
    $response .= extractTerms($result);
    $response .= qq(});
  }
}

elsif($cmd eq 'term_children') {
  my $parent_term = $query->param('term');
  #eval { $result = $client->getTermChildren($parent_term, $ontology, 1, undef); };
  eval { $result = $client->getTermRelations($parent_term, $ontology); };
  if ($@) {
    $response = qq({error: {id: 'webservice_error', msg: 'There was an error when calling the Ontology Lookup Service webservice' extended_msg: $@});
  } else {
    $response = qq({);
    $response .= extractTerms($result);
    $response .= qq(});
  } 
}

elsif($cmd eq 'search') {
  my $str = $query->param('term');
  eval { $result = $client->getTermsByName($str, $ontology, 0); };
  if ($@) {
    $response = qq({error: {id: 'webservice_error', msg: 'There was an error when calling the Ontology Lookup Service webservice' extended_msg: $@});
  } else {
    $response = qq({);
    $response .= extractTerms($result);
    $response .= qq(});
  } 
}

elsif($cmd eq 'ontology_names') {
  eval { $result = $client->getOntologyNames(); };
  if ($@) {
    $response = qq({error: {id: 'webservice_error', msg: 'There was an error when calling the Ontology Lookup Service webservice' extended_msg: $@});
  } else {
    $response = qq({);
    $response .= print "ONTOLOGY_NAMES: ".Dumper($result);
    $response .= qq(});
  } 
}
else {
   $response = qq({error: {id: 'unknown_command', msg: 'The command supplied ($cmd) has not been recognized'});
}

print $response;

exit(0);

sub extractTerms {
  my ($result) = @_;

  print "Results: ".Dumper($result) if($debug);
  my $resp = qq("terms": [);

  if($result eq '') { #No terms returned
      #do nothing
  }  elsif(ref $result->{'item'} eq 'HASH') { #if it's only one element, no array is present
      #$resp .= qq({"name":").$result->{'item'}->{'value'}.qq(","key":").$result->{'item'}->{'key'}.qq("},);
      $resp .= qq({"name":").getTermName($result->{'item'}->{'key'}).qq(","key":").$result->{'item'}->{'key'}.qq("},);  
  #print "now resp is: $resp\n";

  } elsif(ref $result->{'item'} eq 'ARRAY') { #if more than one term, an aray is returned
    for my $term (@{$result->{'item'}}) {
      $resp .= qq({"name":").getTermName($term->{'key'}).qq(","key":").$term->{'key'}.qq("},); 
      #print "now resp is: $resp\n";
    }
  }
  chop($resp) if(substr($resp, -1) eq ',');
  $resp .= qq(]);
  return $resp;
}

sub getTermName {
  my ($id) = @_;
  my $name;
#print "id is: $id\n";
  eval { $name = $client->getTermById($id, $ontology);};
#print "Result: ".Dumper($name);
  if ($@) {
    $response = qq({error: {id: 'webservice_error', msg: 'There was an error when calling the Ontology Lookup Service webservice' extended_msg: $@});
  } else {
      #print "returning name: $name\n";
     return $name; 
  } 
}
