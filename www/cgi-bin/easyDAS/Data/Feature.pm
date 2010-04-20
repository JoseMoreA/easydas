#########
# Author:        bernat gel
# Created:       2009-10-16
#
# Feature
#
# This file contains the class easyDAS::Data::Feature, the class representing a DAS feature
#

package easyDAS::Data::Feature;

use strict;
use warnings;

use Carp;
use Data::Dumper;

#Creates a new feature
#
# if $params is a string, it's used as a feature_id and an empty feature is created
# if $params is a Hash, it's suposed to have some feature information and used as a source. references in $params are copied, 
# NOT cloned, so they will point to the same real data
sub new {
  my ($class, $params, $debug) = @_;

  my $self;
  if(ref $params eq 'HASH') {
    $self = {
	    'id'	=> $params->{'id'},
	    'label'	=> $params->{'label'} || $params->{'name'},
	    'segment'	=> $params->{'segment'} || $params->{'segment_id'},
	    'start' 	=> $params->{'start'},
	    'end'	=> $params->{'end'},
	    'score'	=> $params->{'score'},
	    'orientation'	=> $params->{'orientation'},
	    'phase'	=> $params->{'phase'},
	    'type_id'	=> $params->{'type_id'},
	    'method_id'	=> $params->{'method_id'},
	    'links'	=> $params->{'links'} || [],
	    'notes'	=> $params->{'notes'} || [],
	    'parents'	=> $params->{'parents'} || [],
	    'parts'	=> $params->{'parts'} || []
    };    
  } elsif(ref $params eq 'SCALAR') {
    $self = {
	      'id'	 => $params,
              'debug'    => $debug || 0,
	      'links'	=> [],
	      'notes'	=> [],
	      'parents'	=> [],
	      'parts'	=> []
    };
  }

  bless $self, $class;
  return $self;
}

##### Getters for static properties  #####
sub debug {
  my ($self) = @_;
  return $self->{'debug'};
}

sub id {
  my ($self) = @_;
  return $self->{'id'};
}

######-----  GETTERS/SETTERS  -----######  
sub label {
  my ($self, $value) = @_;
  return $self->_getset('label', $value);
}

#Just an alias for label
sub name {
  my ($self, $value) = @_;
  return $self->label($value);
}

sub segment {
  my ($self, $value) = @_;
  return $self->_getset('segment', $value);
}

#Just an alias for segment
sub segment_id {
  my ($self, $value) = @_;
  return $self->segment($value);
}

sub start {
  my ($self, $value) = @_;
  return $self->_getset('start', $value);
}
sub end {
  my ($self, $value) = @_;
  return $self->_getset('end', $value);
}
sub score {
  my ($self, $value) = @_;
  return $self->_getset('score', $value);
}
sub orientation {
  my ($self, $value) = @_;
  return $self->_getset('orientation', $value);
}
sub  phase{
  my ($self, $value) = @_;
  return $self->_getset('phase', $value);
}

sub type_id {
  my ($self, $value) = @_;
  return $self->_getset('type_id', $value);
}
sub method_id  {
  my ($self, $value) = @_;
  return $self->_getset('method_id', $value);
}
sub links {
  my ($self, $value) = @_;
  return $self->_getset('links', $value);
}
sub notes {
  my ($self, $value) = @_;
  return $self->_getset('notes', $value);
}
sub parents {
  my ($self, $value) = @_;
  return $self->_getset('parents', $value);
}
sub parts {
  my ($self, $value) = @_;
  return $self->_getset('parts', $value);
}

######  Adders: add an element to the array based values
sub add_link {
  my ($self, $value) = @_;
  return $self->_addvalue('links', $value);
}
sub add_note {
  my ($self, $value) = @_;
  return $self->_addvalue('notes', $value);
}
sub add_parent {
  my ($self, $value) = @_;
  return $self->_addvalue('parents', $value);
}
sub add_part {
  my ($self, $value) = @_;
  return $self->_addvalue('parts', $value);
}

###################  ADTIONL METHODS     ###################
#Checks if the feature is "complete", in the sense that it has the minimum information needed to add it to the DB
sub complete {
  my ($self) = @_;
  return (defined $self->id 
      &&  defined $self->segment
      &&  defined $self->start 
      &&  defined $self->end
      &&  defined $self->orientation
      &&  defined $self->phase
      &&  defined $self->type_id);
 #TODO: Add method_id too
}

###################   UTILITY FUNCTIONS  ###################
sub _getset {
  my ($self, $key, $value) = @_;
  $self->{$key} = $value if(defined $value);
  return $self->{$key};
}

sub _addvalue {
  my ($self, $key, $value) = @_;
  push(@{$self->{$key}}, $value);
  return $self;
}



1;


