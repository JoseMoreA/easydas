#########
# Author:        bernat gel
# Created:       2009-10-07
#
# File Metadata control
#
# This module provides easyDAS with its file metadata system. Given a data file a different metadata file is created
#

package easyDAS::FileMetadata;

use strict;
use warnings;

use Carp;
use File::Spec;

use JSON;

use Data::Dumper;


#Defines
my $temp_dir = "./tmpFiles";
my $metadata_extension = "metadata";

sub new {
  my ($class, $params) = @_;

  if(!$params->{'file_id'}) {
    die qq(Can't create a FileMetadata without file_id!!!!);
  }

  #Create  self
  my $self = {
              'initial_params'    => $params,
              'debug'             => $params->{'debug'} || undef,
	      'file_id'		  => $params->{'file_id'},
	      'temp_dir'	  => $temp_dir,
	      'metadata_extension'=> $metadata_extension
             };

  bless $self, $class;

  #Check if the metadata file exists
  if( -e $self->{'file_id'}.".metadata") {
      $self->load();
  } else {
      my $ext = substr($params->{'original_filename'}, rindex($params->{'original_filename'}, '.')+1);
      my %metadata = (
		file_id => $params->{'file_id'},
		original_filename => $params->{'original_filename'},
		extension => $ext,
		types => [],
		methods => [],
		segments => [],
		defaults => $self->get_standard_defaults,
		source => {},
		parsing => {}, #info about the parsing parameters, etc... Obtained by testing
		user => {username => $params->{'username'}}, #TODO: Add user security (tokens, etc...)
		parsed_data => {
		  parsed => 0
		}, #info about the data actually parsed and stord in DB, etc...
		easyDAS_fields => $self->get_easyDAS_fields
      );
      $self->{'metadata'} = \%metadata;
      #print "METADATA (newly created): ".Dumper($self->{'metadata'})."<br>\n";
  }
  return $self;
}

sub newFromString  {
    my ($class, $str) = @_;
    
    #Create  self
    my $self = {};
    bless $self, $class;
    $self->{'metadata'} = $self->fromJSON($str);

    #mimic the original metdata object
    $self->{'initial_params'}	  = $self->{'metadata'};
    $self->{'debug'}              = $self->{'metadata'}->{'debug'} || undef;
    $self->{'file_id'}		  = $self->{'metadata'}->{'file_id'};
    $self->{'temp_dir'}	  	  = $temp_dir;
    $self->{'metadata_extension'} = $metadata_extension;
    
    return $self;
}




#############################################################################################################
#                                                                                                           #
#                                  Public Functions                                                         #
#                                                                                                           #
#############################################################################################################

sub toJSON { #returns the metadata in a JSON string
  my ($self, $pretty) = @_;
  $pretty ||= 0;
  return JSON->new->utf8(1)->pretty($pretty)->encode($self->{'metadata'});
}

sub fromJSON { #creates a metadata object from a JSON string
  my ($self, $str) = @_;
  return JSON->new->decode($str);
}

sub save { #Convert $self->metadata to a JSON string and save it to the metadata file
    my ($self) = @_;

    #my $fname = File::Spec->catfile($self->{'temp_dir'}, $self->{'file_id'});
    my $fname = $self->{'file_id'}.".metadata";
    
    open (METADATA, "> $fname") || die "<h1> Can't Open $fname for storing metadata</h1>";
    my $json_text = $self->toJSON(1);
    print METADATA $json_text; 
    close METADATA;
    return $self;
}

sub load { #Load the metadata file, parse its JSON content and ans store it in $self->metadata
    my ($self) = @_;

    #my $fname = File::Spec->catfile($self->{'temp_dir'}, $self->{'file_id'});
    my $fname = $self->{'file_id'}.".metadata";

    #print qq(Opening $fname<br>\n);
    
    open (METADATA, "< $fname") || die "<h1> Can't Open $fname for retrieving metadata</h1>";
    my @lines = <METADATA>;
    my $lines = join("", @lines);
    #print "The big json line: $lines<br>\n";
    $self->{'metadata'} = JSON->new->decode($lines);
    close METADATA;
    return $self;
}


####################################  GETTERS AND SETTERS  ###########################################
sub metadata {
   my ($self, $value) = @_;
   $self->{'metadata'} = $value if (defined $value);
   return $self->{'metadata'};
}

#file_id CANNOT be changed, since it's what identifies the metadata
sub file_id {
   my ($self) = @_;
   return $self->{'file_id'};
}
sub original_filename {
   my ($self, $value) = @_;
   if (defined $value) {
      $self->{'metadata'}->{'original_filename'} = $value;
      $self->{'metadata'}->{'extension'} = substr($value, rindex($value, '.')+1);
   }
   return $self->{'metadata'}->{'original_filename'};
}
#the extension cannot be changed. Depens on the original filename
sub extension {
   my ($self, $value) = @_;
   return $self->{'metadata'}->{'extension'};
}
##TODO: Should we fail loudly if the value is not of a suitable type?
sub types {
   my ($self, $value) = @_;
   $self->{'metadata'}->{'types'} = $value if (defined $value and ref($value) eq 'ARRAY');
   return $self->{'metadata'}->{'types'};
}
sub methods {
   my ($self, $value) = @_;
   $self->{'metadata'}->{'methods'} = $value if (defined $value and ref($value) eq 'ARRAY');
   return $self->{'metadata'}->{'methods'};
}
sub segments {
   my ($self, $value) = @_;
   $self->{'metadata'}->{'segments'} = $value if (defined $value and ref($value) eq 'ARRAY');
   return $self->{'metadata'}->{'segments'};
}
sub defaults {
   my ($self, $value) = @_;
   $self->{'metadata'}->{'defaults'} = $value if (defined $value and ref($value) eq 'ARRAY');
   return $self->{'metadata'}->{'defaults'};
}
sub parsing {
   my ($self, $value) = @_;
   $self->{'metadata'}->{'parsing'} = $value if (defined $value and ref($value) eq 'HASH');
   return $self->{'metadata'}->{'parsing'};
}
sub source {
   my ($self, $value) = @_;
    
   $self->{'metadata'}->{'source'} = $value if (defined $value and ref($value) eq 'HASH');
   return $self->{'metadata'}->{'source'};
}
sub parsed_data {
   my ($self, $value) = @_;
   $self->{'metadata'}->{'parsed_data'} = $value if (defined $value and ref($value) eq 'HASH');
   return $self->{'metadata'}->{'parsed_data'};
}

sub remove_testing_data {
  my ($self) = @_;
  $self->parsing->{'data'} = [];
}

sub created_source {
  my ($self, $value) = @_;
  $self->{'metadata'}->{'created_source'} = $value if (defined $value);
  $self->{'metadata'}->{'created_source'} = {} if (!defined $self->{'metadata'}->{'created_source'});
  return $self->{'metadata'}->{'created_source'};
}

sub defaults {
  my ($self, $value) = @_;
  $self->{'metadata'}->{'dafaults'} = $value if(defined $value);
  return $self->{'metadata'}->{'defaults'};
}

sub user {
   my ($self, $value) = @_;
   $self->{'metadata'}->{'user'} = $value if (defined $value and ref($value) eq 'HASH');
   return $self->{'metadata'}->{'user'};
}

sub coordinates_system {
   my ($self, $value) = @_;
   $self->{'metadata'}->{'source'}->{'coordinates_system'} = $value if (defined $value and ref($value) eq 'HASH');
   return $self->{'metadata'}->{'source'}->{'coordinates_system'};
}

sub error {
  my ($self, $value) = @_;
  $self->metadata->{'error'} = $value;
} 
################################################# END OF "INTERFACE" ########################################33

sub debug {
   my ($self, $value) = @_;
   $self->{'debug'} .= $value if (defined $value);
   return $self->{'debug'};
}

#Only to be used by file-based Input Adaptors... but MOST of them will be
sub _fh {
  my $self = shift;

  if(!$self->{'fh'}) {
    my $fn = $self->{'filename'};
    open $self->{'fh'}, q(<), $fn or croak qq(Could not open $fn);
  }
  return $self->{'fh'};
}

sub checkFileExtension {
  my $self = shift;

  my $fn = $self->{'original_filename'};
  my $ext = $self->file_extension();
  my $valid = $self->{'file_extensions'};
  foreach my $valid_extension (@$valid) { 
     return 1 if(lc($valid_extension) eq lc($ext));
  }
  return 0;
}

sub file_extension {
  my $self = shift;
  my $fn = $self->{'original_filename'};
  return substr($fn, rindex($fn, '.')+1);
}

#########
sub get_easyDAS_fields {
  my $data_fields = [
	{id=> 'id', name=> 'Identifier'},
	{id=> 'name', name=> 'Name'},
	{id=> 'start', name=> 'Start'},
	{id=> 'end', name=> 'End'},
	{id=> 'score', name=> 'Score'},
	{id=> 'orientation', name=> 'Orientation'},
	{id=> 'phase', name=> 'Phase'},
	{id=> 'method_id', name=> 'Method Id'},
	{id=> 'notes', name=> 'Note'},
	{id=> 'segment_id', name=> 'Segment Id'},
	{id=> 'type_id', name=> 'Type Id'},
	{id=> 'parents', name=> 'Parents'},
	{id=> 'parts', name=> 'Parts'},
	{id=> 'links', name=> 'Link'}
    ];
    return $data_fields;
}

sub get_standard_defaults {
  return [
    {field => 'orientation', condition => 'is_empty', value => '0'},
    {field => 'phase', condition => 'is_empty', value => '-'}
  ];
}


######################################


#############################METADATA SETTERS/GETTERS#########################################
#Adds an ontology to the ontologi
sub add_ontology {
  my ($self, $value) = @_;
  #push($self->{'guessed_metadata'}->{'feature_ontologies'}, $value) if (defined $value);
  return;
}

sub organism {	
  my ($self, $value) = @_;
  $self->{'guessed_metadata'}->{'organism'} = $value if (defined $value);
  return $self->{'guessed_metadata'}->{'organism'};
}

sub source_name {	
  my ($self, $value) = @_;
   $self->{'guessed_metadata'}->{'source_name'} = $value if (defined $value);
  return $self->{'guessed_metadata'}->{'source_name'};
}

sub source_description {	
  my ($self, $value) = @_;
  $self->{'guessed_metadata'}->{'source_description'} = $value if (defined $value);
  return $self->{'guessed_metadata'}->{'source_description'};
}

sub source_mantainer {	
  my ($self, $value) = @_;
   $self->{'guessed_metadata'}->{'source_mantainer'} = $value if (defined $value);
  return $self->{'guessed_metadata'}->{'source_mantainer'};
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

1;