#########
# Author:        Bernat Gel
# Maintainer:    Bernat Gel
# Created:       2009-09-21
#
# This is a specialized InputAdaptor for a Generic Column Based Text file format. 
#
# GFF is a specialization of this format 
# TODO: make GFF a formal child of this one?
#

package easyDAS::InputAdaptor::ColumnBasedText;

use strict; 
use warnings;

use File::stat;
use Carp;
use Error qw(:try); #Add try/catch syntax

use Data::Dumper;

use base qw(easyDAS::InputAdaptor);

sub init {
  my ($self, $config) = @_;

  #Set the expected file extensions
  my @file_exts = ('tab', 'dat', 'csv');
  $self->{'file_extensions'} = \@file_exts;
  $self->{'error_message'} = "";
}


##################GETTERS/SETTERS#####################################################


###################################################################################
#                                                                                 #
#                    Metadata management                                          #
#                                                                                 #
###################################################################################


=head4 get_parsing_metadata

 Function  : Returns a valid parsing metadata. Creates or adapts it if necessary
 Arguments : 
 Returns   : $metadata
 
=cut
sub get_parsing_metadata {
  my ($self) = @_;
  
  my $meta = $self->metadata;
  if($meta->parsing) && $meta->parsing->{'parsingtype'} && $meta->parsing->{'parsingtype'} eq 'ColumnBasedText') { #IF the parsing section is of type GFF
	  return $meta->parsing;
  }
  #if arrived here, we don't have a valid parsing section. Create one
  #WARNING: WHAT IF the user forced the cuurent parsing type? We should not be here!!!
  $meta->parsing($self->create_parsing_metadata);
  return $meta->parsing;
}

=head4 create_parsing_metadata

 Function  : creates a parsing metadata section for the ColumnBasedText format
 Arguments : 
 Returns   : $metadata

=cut
sub create_parsing_metadata {
  my ($self) = @_;
  
  my $parsing = (
    parsingtype => "ColumnBasedText",
    parser => "easyDAS::InputAdaptor::ColumnBasedText",
    parser_parameters: {}
  );
  
  return $parsing;
}

=head4 column_headers

 Function  : sets or retrieves the headers information. If setting, it also sets the headers directive to true.
 Arguments : $headers -> array of strings
 Returns   : $headers -> array of strings

=cut
sub column_headers {
  my ($self) = @_;
  carp qq(TODO: Implement);
  return $parsing;
}

=head4 column_headers

 Function  : sets or retrieves the headers information. If setting, it also sets the headers directive to true.
 Arguments : $headers -> array of strings
 Returns   : $headers -> array of strings

=cut
sub column_headers {
  my ($self) = @_;
  carp qq(TODO: Implement);
  return $parsing;
}

################## "REAL" METHODS ###################################################

1;