#########
# Author:        bernat gel
# Created:       2003-05-20
#
# Generic InputAdaptor.
#
# This is the base class for all the InputAdaptors used in easyDAS
#

package easyDAS::InputAdaptor;

use strict;
use warnings;

use Carp;
use File::Spec;

use easyDAS::DBInterface;

use Data::Dumper;

sub new {
  my ($class, $meta, $config) = @_;

  my @extensions = ();
  my $self = {
	      'filename'	=> $meta->{'file_id'},
              'config'          => $config || undef,
              'debug'           => $config->{'debug'} || undef,
	      'file_extensions' => \@extensions,
	      'metadata' 	=> $meta
             };

  bless $self, $class;
  $self->init($config);
  
  return $self;
}

############################### BEGIN OF INTERFACE #############################################
#
#         Subclasses should overide those functions and add some functionality to them         #
#
################################################################################################

#Initialization process. Will take place AfTER the parent class initialization
sub init {return;}

#Return true iif the file seems to be of a partícular type.
#return false in the interface implementation
sub test {
    return -1;
}

#Return true iif the file seems to be of a partícular type.
#return false in the interface implementation
sub create_source {
    return -1;
}

######################################################################
#          PUBLIC API
######################################################################

sub metadata {
   my ($self, $value) = @_;
   $self->{'metadata'} = $value if (defined $value); #TODO: Check its a valid metadata object
   return $self->{'metadata'};
}

#Returns a valid parsing metadata. Creates or adapts it if necessary
sub get_parsing_metadata {
  my ($self) = @_;
  
  my $meta = $self->metadata;
  if($meta->parsing) { #IF there is a parsing section, use it
	  return $meta->parsing;
  }
  #if arrived here, we don't have a valid parsing section. Create one
  #WARNING: WHAT IF the user forced the cuurent parsing type? We should not be here!!!
  $meta->parsing($self->create_parsing_metadata);
  return $meta->parsing;
}

#creates a parsing metadata section for the GFF format
sub create_parsing_metadata {
  my ($self) = @_;
  
  my $parsing = (
    parser_type => "GenericParser",
    parser => "easyDAS::InputAdaptor",
  );
  
  return $parsing;
}


sub create_feature  {
    my ($self, $fields_ref, $line_num) = @_;

    my @fields = @{$fields_ref};


    #create all the feature info based on the defined mapping
    my @mapping = @{$self->metadata->parsing->{'mapping'}};
    
    my $feat_info = {};
    foreach my $map (@mapping) {
      my $edF = $map->{'easyDAS_field'};
      if(!$feat_info->{$edF}) {
	$feat_info->{$edF} = $fields[$map->{'data_field'}];#$fields[$self->get_data_field_position($map->{'data_field'})];
      } else {
	#if two fields are mapped to the same easyDAS_field we need use an array
	if(ref($feat_info->{$edF}) ne 'ARRAY') { #if still not an array, convert it
	  my @arr = ($feat_info->{$edF});
	  $feat_info->{$edF} = \@arr;
	}
	push @{$feat_info->{$edF}}, $fields[$map->{'data_field'}]; #and push the new content
      }
    }
    #Some fields may be arrays. For those in fields accepting arrays, no nothing. For the rest, use the first element.
    foreach my $k (keys %{$feat_info}) {
      if(ref($feat_info->{$k}) eq 'ARRAY') {
	if($k ne 'notes' && $k ne 'links' && $k ne 'parents' && $k ne 'parts') {
	 #print "flattening $k to ".@{$feat_info->{$k}}[0]." from ".Dumper($feat_info->{$k})."\n";
	  $feat_info->{$k} = @{$feat_info->{$k}}[0];
	}
      }
    }

    #HACK: finally, add an id if no one is present. To make it unique use the file line number
    $feat_info->{'id'} ||="feature_".$line_num;

    my $feature = easyDAS::Data::Feature->new($feat_info);
    return $feature;
}



#Adds a type to the types structure iif it's not already there
sub add_type {
  my ($self, $t) = @_;
  if(!defined $t) {return};
  $self->metadata->{'current_types'} or $self->metadata->{'current_types'}={}; #initialize current_types if necessary
  if(!$self->metadata->{'current_types'}->{$t}) {
    $self->metadata->{'current_types'}->{$t} = 1;
    my $type_info = $self->get_old_type_info($t) || {id => $t};
    push(@{$self->metadata->types}, $type_info);
    
  }
  return;
}

sub reset_types {
  my ($self) = @_;
  $self->metadata->{'current_types'} = {};
  $self->{'old_types'} = $self->metadata->types if($self->metadata->types && scalar @{$self->metadata->types} > 0);
  $self->metadata->types([]);
}

#if we are retesting for some reason, types info might be already entered, so try to use it if available
sub get_old_type_info {
  my ($self, $t) = @_;
  if($self->{'old_types'}) {
    foreach my $ot (@{$self->{'old_types'}}) {
      if($ot->{'id'} eq $t) {
	return $ot;
      }
    }
  }
  #if there was no info in the metadata, maybe in the DB
  my $DB = $self->getDB();
  my $type_info = $DB->getTypeInfo($self->metadata->user->{'username'}, $t);
  if(scalar @{$type_info}) { 
    return {id=>$type_info->[1], label=>$type_info->[2], cvId=>$type_info->[4]}; 
  }
  return undef;
}


#METHODS
#Adds a method to the methods structure iif it's not already there
sub add_method {
  my ($self, $t) = @_;
  #print "Adding method: ".Dumper($t)."\n";
  if(!defined $t) {return};
  $self->metadata->{'current_methods'} or $self->metadata->{'current_methods'}={}; #initialize current_methods if necessary
  if(!$self->metadata->{'current_methods'}->{$t}) {
#print "Adding to current methods\n";
    $self->metadata->{'current_methods'}->{$t} = 1;
    my $method_info = $self->get_old_method_info($t) || {id => $t};
    push(@{$self->metadata->methods}, $method_info);
    
  }
#print "Now methods id: ".Dumper(@{$self->metadata->methods})."\n";
  return;
}

sub reset_methods {
  my ($self) = @_;
  $self->metadata->{'current_methods'} = {};
  $self->{'old_methods'} = $self->metadata->methods if($self->metadata->methods && scalar @{$self->metadata->methods} > 0);
  $self->metadata->methods([]);
}

#if we are retesting for some reason, types info might be already entered, so try to use it if available
sub get_old_method_info {
  my ($self, $t) = @_;
  if($self->{'old_methods'}) {
    foreach my $ot (@{$self->{'old_methods'}}) {
      if($ot->{'id'} eq $t) {
	return $ot;
      }
    }
  }
  #if there was no info in the metadata, maybe in the DB
  my $DB = $self->getDB();
  my $method_info = $DB->getMethodInfo($self->metadata->user->{'username'}, $t);
  if(scalar @{$method_info}) { 
    return {id=>$method_info->[1], label=>$method_info->[2], cvId=>$method_info->[3]}; 
  }
  return undef;
}


#Gather extended info (types, segments, etc...) based on the data on the $data archive
sub extract_extended_info {
  my ($self, $data) = @_;
 
  my @mapping = @{$self->metadata->parsing->{'mapping'}};
    
  foreach my $map (@mapping) {
#print "Extended info extractio: ".$map->{'easyDAS_field'}."\n";
    if($map->{'easyDAS_field'} eq 'type_id') {
      #foreach my $d (@{$data}) {
#	my $t=(ref($d->[$map->{'data_field'}]) eq 'ARRAY')?$d->[$map->{'data_field'}]->[0]:$d->[$map->{'data_field'}];
#        $self->add_type($t);
#      }
	$self->add_type($data->[$map->{'data_field'}]);
    }
    if($map->{'easyDAS_field'} eq 'method_id') {
	$self->add_method($data->[$map->{'data_field'}]);
    }
  }
}

sub apply_defaults {
  my ($self, $feature) = @_;
  
  for my $def (@{$self->metadata->defaults}) {
    my $field = $def->{'field'};
    if(($def->{'condition'} eq 'always') || (($def->{'condition'} eq 'is_empty') && (!defined $feature->$field))) {
       #print "defaulting field $field to value ".$def->{'value'}."\n";
      $feature->$field($def->{'value'});
    }
  }
}


sub guess_mapping {
  my ($self) = @_;
  my @mapping = @{$self->metadata->parsing->{'mapping'}};
  return if(scalar @mapping >0); #if any mapping is present, do nothing
  my $num_field =0;
  for my $field (@{$self->metadata->parsing->{'data_fields'}}) {
     my $field_name = $field->{'name'};
     $self->guess_mapping_for_field($field_name, $num_field);
     $num_field++;
  }
}

sub guess_mapping_for_field {
  my ($self, $field, $num_field) = @_;
  my $mapping = $self->metadata->parsing->{'mapping'};
  if(!$self->field_has_mapping($mapping, $num_field)) {
   # print "Trying to assign a mapping to: $field ($num_field)\n";
    chomp($field);
    $field = lc($field);
    $field = substr($field, 10) if(substr($field, 0, 10) eq 'attribute');
    if($field eq 'id' || $field eq 'identifier') {
      push(@{$mapping}, {'easyDAS_field' => 'id', 'data_field'=>$num_field});
    } elsif($field eq 'start') {
      push(@{$mapping}, {'easyDAS_field' => 'start', 'data_field'=>$num_field});
    } elsif($field eq 'end') {
      push(@{$mapping}, {'easyDAS_field' => 'end', 'data_field'=>$num_field});
    } elsif($field eq 'name' || $field eq 'label') {
      push(@{$mapping}, {'easyDAS_field' => 'name', 'data_field'=>$num_field});
    } elsif($field =~ /method/) {
      push(@{$mapping}, {'easyDAS_field' => 'method_id', 'data_field'=>$num_field});
    } elsif($field =~ /parent/) {
      push(@{$mapping}, {'easyDAS_field' => 'parents', 'data_field'=>$num_field});
    } elsif($field =~ /part/) {
      push(@{$mapping}, {'easyDAS_field' => 'parts', 'data_field'=>$num_field});
    } elsif($field =~ /link/) {
      push(@{$mapping}, {'easyDAS_field' => 'links', 'data_field'=>$num_field});
    } elsif($field =~ /type/) {
      push(@{$mapping}, {'easyDAS_field' => 'type_id', 'data_field'=>$num_field});
    } elsif($field =~ /segment/ || $field =~ /^seq/ || $field eq 'ep' || $field =~ /^chr/ || $field =~ /^prot/ || $field =~ /^unip(.)*id/ ) {
      push(@{$mapping}, {'easyDAS_field' => 'segment_id', 'data_field'=>$num_field});
    } elsif($field =~ /^note/) {
      push(@{$mapping}, {'easyDAS_field' => 'notes', 'data_field'=>$num_field});
    } elsif($field =~ /start/) {
      push(@{$mapping}, {'easyDAS_field' => 'start', 'data_field'=>$num_field});
    } elsif($field =~ /end/) {
      push(@{$mapping}, {'easyDAS_field' => 'end', 'data_field'=>$num_field});
    } elsif($field =~ /score/) {
      push(@{$mapping}, {'easyDAS_field' => 'score', 'data_field'=>$num_field});
    } elsif($field =~ /^ori/ || $field =~ /strand/) {
      push(@{$mapping}, {'easyDAS_field' => 'orientation', 'data_field'=>$num_field});
    } elsif($field =~ /phase/) {
      push(@{$mapping}, {'easyDAS_field' => 'phase', 'data_field'=>$num_field});
    } elsif($field =~ /name/) {
      push(@{$mapping}, {'easyDAS_field' => 'name', 'data_field'=>$num_field});
    } elsif($field =~ /id/) {
      push(@{$mapping}, {'easyDAS_field' => 'id', 'data_field'=>$num_field});
    } elsif($field =~ /(entry)(.)*(point)/) {
      push(@{$mapping}, {'easyDAS_field' => 'id', 'data_field'=>$num_field});
    }
    #TODO: $field eq 'acc' || $field eq 'accession' -> DBxref
  }
}

sub field_has_mapping {
  my ($self, $mapping, $num_field) = @_;
  for my $map (@{$mapping}) {
   # print "comparing: ".$map->{'data_field'}." and $num_field\ns";
    return 1 if($map->{'data_field'} eq $num_field);
  }
  return 0;
}
################################################# END OF "INTERFACE" ########################################

sub debug {
   my ($self, $value) = @_;
   $self->{'debug'} = $value if (defined $value);
   return $self->{'debug'};
}

#Only to be used by file-based Input Adaptors... but MOST of them will be
sub _fh {
  my $self = shift;

  if(!$self->{'fh'}) {
    my $fn = $self->metadata->file_id;
    open $self->{'fh'}, q(<), $fn or croak qq(Could not ooopen $fn);
  }
  
  return $self->{'fh'};
}

sub file_size {
  my $self = shift;
  $self->{'_file_size'} = -s $self->metadata->file_id if(!$self->{'_file_size'});
  return $self->{'_file_size'};
}
  
  

sub checkFileExtension {
  my $self = shift;

  my $valid = $self->{'file_extensions'};
  foreach my $valid_extension (@$valid) { 
      return 1 if(lc($valid_extension) eq lc($self->metadata->extension));
  }
  return 0;
}

sub getDB {
  my ($self)= @_;

  if(!$self->{'_dbh'}) {
    $self->{'_dbh'} = easyDAS::DBInterface->new($self->debug);
  }
  return $self->{'_dbh'};
}

#############################METADATA SETTERS/GETTERS#########################################
#Adds an ontology to the ontology lists
sub add_ontology {
  my ($self, $value) = @_;
  #TODO: Right now we are ignoring the ontologies!!! should we?
  #push($self->{'guessed_metadata'}->{'feature_ontologies'}, $value) if (defined $value);
  return;
}

#TODO: Those function should be part of the FileMetadata structure, not part of the adaptor!!
sub organism {	
  my ($self, $value) = @_;
  $self->metadata->source->{'organism'} = $value if (defined $value);
  return $self->metadata->source->{'organism'};
}

sub source_name {	
  my ($self, $value) = @_;
  $self->metadata->source->{'source_name'} = $value if (defined $value && !$self->metadata->source->{'forced_source_name'});
  return $self->metadata->source->{'source_name'};
}

sub source_title {	
  my ($self, $value) = @_;
   $self->metadata->source->{'source_title'} = $value if (defined $value && !$self->metadata->source->{'forced_source_title'});
  return $self->metadata->source->{'source_title'};
}

sub source_description {	
  my ($self, $value) = @_;
  $self->metadata->source->{'source_description'} = $value if (defined $value && !$self->metadata->source->{'forced_source_description'});
  return $self->metadata->source->{'source_description'};
}

sub source_mantainer {	
  my ($self, $value) = @_;
   $self->metadata->source->{'source_mantainer'} = $value if (defined $value && !$self->metadata->source->{'forced_source_maintainer'});
  return $self->metadata->source->{'source_mantainer'};
}


############################ FORMAT TESTING MANAGEMENT ##########################################

sub error_message { #Kind of a log where to stack-up the error messages we generate
    my ($self, $value) = @_;
    $self->{'error_message'} .= $value."\n" if (defined $value);
    return $self->{'error_message'};
}

#We define an error score with 0 being "Totally sure is THIS format" and 100 being "Completely sure it's NOT this format"

sub error_score {	
  my ($self, $value) = @_;
   $self->{'error_score'} = $value if (defined $value);
  return $self->{'error_score'};
}

#returns a "normalized" value for the error between 0 and 100
sub normalized_error_score {
  my ($self) = @_;
  my $es = $self->{'error_score'};
  $es = 100 if($es > 100);
  $es = 0 if($es < 0);
  return $es;
}

sub reset_error_score {
  my ($self) = @_;
  return $self->error_score(0);
}

sub add_error_score {
  my ($self, $value) = @_;
  $self->{'error_score'} += $value;
  return $self->{'error_score'};
}

#And the same functions for a "line score" to track the likeliness of a given line to be part of a gff
sub line_error_score {	
  my ($self, $value) = @_;
   $self->{'line_error_score'} = $value if (defined $value);
  return $self->{'line_error_score'};
}

#returns a "normalized" value for the error between 0 and 100
sub normalized_line_error_score {
  my ($self) = @_;
  my $es = $self->{'line_error_score'};
  $es = 100 if($es > 100);
  $es = 0 if($es < 0);
  return $es;
}

sub reset_line_error_score {
  my ($self) = @_;
  return $self->line_error_score(0);
}

sub add_line_error_score {
  my ($self, $value) = @_;
  $self->{'line_error_score'} += $value;
  return $self->{'line_error_score'};
}

#################################UTILITY FUNCTIONS ######################



sub escape_quotes {
  my ($self, $v) = @_;
  my $fc = substr($v, 0, 1);
  if(($fc eq '"' || $fc eq "'") && $fc eq substr($v, -1, 1)) {
	$v = substr($v, 1, (length $v) -2);
  }
  return $v;
}

sub trim_data_line {
  my ($self, $data_line) = @_;
  foreach(@{$data_line}) {
	if(length $_ > 20) {
		$_ = substr($_, 0, 20).'...';
	}
  }
  return $data_line
}
1;
