#########
# Author:        bernat gel
# Created:       2003-05-20
#
# File Tester
#
# This file contains the logic guiding the format discovery and metadata adquisition.
#

package easyDAS::Controller;

use strict;
use warnings;

use Carp;
use File::Spec;
use Clone::Fast qw(clone);

use Data::Dumper;

use easyDAS::FileMetadata;
use easyDAS::InputAdaptor;
use easyDAS::InputAdaptor::GFF;
use easyDAS::InputAdaptor::CSV;


sub new {
  my ($class, $debug) = @_;
    
  my $self = {
              'debug'    => $debug || 0, #OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
	      'min_score_threshold' => 80 #The fixed score beyond the file is accepted as being of that filetype
             };
  
  bless $self, $class;
  return $self;
}

#######################################################################################################
#												      #
#				Public Functions                                                       #
#												      #
#######################################################################################################

#Tests the file and tries to find out its type, structure and data.
#return a metadata object with all its metainformation
sub test {
  my ($self, $metadata) = @_;

  #my $metadata = $meta->metadata;
   
  #set a flag saying we don't know the format
  $metadata->parsing->{'format_guesing_success'} = 0;
  #Try to infer the file format of $file and then try to get the most of it
  print qq(Begin Testing....) if($self->debug);
  #TODO: Maybe some basic heuristics to guide the search... (start with the formats accepting the file extension, test a couple of lines...)


  if(!$metadata->{'forced_parser_type'}) {
	#If no format was forced by the user, try to guess it from the content
	print qq(No format hint provided. Try heuristics to guess it\n) if($self->debug);
   
 	 if($metadata->file_extension() eq 'xls') {
	      $metadata->{'error'} = {id=>"unsuported_format", msg =>"Excel Support still not implemented."};
	      return $metadata;
	  } else {
  
    	#Test GFF
	    print qq(Trying with GFF\n) if($self->debug);
   
	    my $temp_metadata = clone($metadata); #Prepare a cloned metadata for the adaptor to play
	    my $gff = easyDAS::InputAdaptor::GFF->new($temp_metadata, {debug=>$self->debug}); #Create the GFF adaptor
	    $gff->test();
	    
	    #if successful
	    print "Score for GFF is: ".$temp_metadata->parsing->{'format_score'}."   and minimal score is: ".$self->{'min_score_threshold'}."<br>\n" if($self->debug);
	    if($temp_metadata->parsing->{'format_score'} >= $self->{'min_score_threshold'}) {
	      print "Accepeted as a GFF<br>\n" if($self->debug);
	      $temp_metadata->{'format_guessing_success'} = 1;
	      $metadata = $temp_metadata;
	    } else {
	      #if it's not GFF, try with CSV
	      print qq(It is not a GFF. Try with CSV\n) if($self->debug);
	      $temp_metadata = clone($metadata); #Prepare a cloned metadata for the adaptor to play
	      my $csv = easyDAS::InputAdaptor::CSV->new($temp_metadata, {debug=>$self->debug}); #Create the CSV adaptor
	      $csv->test();
	  
	      #if successful
	      if($temp_metadata->parsing->{'format_score'} >= $self->{'min_score_threshold'}) {
	        $temp_metadata->{'format_guessing_success'} = 1;
	        $metadata = $temp_metadata;
	      } else {
	        #it's not a CSV file. Keep testing
	      }
	    }
	  }
	  print "Sucess: ".$metadata->{'format_guessing_success'}."<br>\n" if($self->debug);
	  if(!$metadata->{'format_guessing_success'}) {
	    $metadata->error({id => 'no_valid_format', msg => 'The file format was not identified. Is it one of the supported formats? Could you give easyDAS a hint by selecting it from the "File Format" selector?'});
    	    return $metadata;
          }
  } else {
	print qq(The file format ).$metadata->{'forced_parser_type'}.qq( has been forced by the user\n) if($self->debug);
	#if the user entered a format request, honour it
	my $parser_name = "easyDAS::InputAdaptor::".$metadata->{'forced_parser_type'};
	print qq(Parser name is: $parser_name\n) if($self->debug);
    	my $parser = $parser_name->new($metadata, {debug=>$self->debug}); #Create the input adaptor
	print qq(Parser created\n) if($self->debug);
	#try to get the most info from it...
	$parser->test();
	print qq(File Tested\n) if($self->debug);
	#and treat it as a successful parsing attepmt
        $metadata->{'format_guessing_success'} = 1;
  }

  #Save the final metadata
  $metadata->save();
  return $metadata;
}

#Tests the file based on the information contained in metadata. The file IS NOT UPLOADED!
sub retest {
  my ($self, $metadata) = @_;

  #remove the data from any previous test
  $metadata->remove_testing_data();

  #and retest
  return $self->test($metadata);
}

#Tests the file and tries to find
sub create_source {
  my ($self, $metadata) = @_;

  #$self->{'debug'} = 1; 

  print qq(Begin Source Creation....) if($self->debug);
  
  my $parsing = $metadata->parsing;
  my $parser_type = $metadata->parsing->{'parser_type'};
  my $handler;
  if(defined $parsing && $parser_type ne 'GenericParser') {
    my $class = 'easyDAS::InputAdaptor::'.$parser_type;
    $handler = $class->new($metadata, {debug=>$self->debug}); #Create the GFF adaptor
  } else {
    print qq(The provided metadata does not specify a parser<br>\n);
    return -1; #TODO: specify error returns....
  }
   
  #create the DBInterface
  my $DB = easyDAS::DBInterface->new($self->debug);
  #and tell the handler to create the database
  
  $metadata = $handler->create_source($DB);

  if(!$metadata->{'error'}) {
  #print "METADATA OK \n";
    #create the created source structure
    $metadata->created_source->{'num_features'} = $metadata->parsed_data->{'features_parsed'};
    $metadata->created_source->{'num_types'} = scalar @{$metadata->types};
    my $dsn = $metadata->source->{'source_name'};
    my $username =  $metadata->user->{'username'} || 'anonymous';
   $metadata->created_source->{'source_url'} = "{DASHOST}/".$DB->get_server_name($username)."/das/$dsn";
    #TDOO: Get the real data
    $metadata->created_source->{'num_segments'} = scalar @{$metadata->segments};
    #print "Metadata with created source is: ".Dumper($metadata)."\n";
    #Save the final metadata
    $metadata->save();
  } else {
   # print "METADATA ERROR! ".Dumper($metadata);
  }
  return $metadata;
}




#######################################################################################################
#												      #
#				Utility Functions                                                     #
#												      #
#######################################################################################################

sub _fh {
  my $self = shift;

  if(!$self->{'fh'}) {
    my $fn = $self->{'filename'};
    open $self->{'fh'}, q(<), $fn or croak qq(Could not open $fn);
  }
  return $self->{'fh'};
}

sub debug {
  my ($self) = @_;
  return $self->{'debug'};
}

1;
