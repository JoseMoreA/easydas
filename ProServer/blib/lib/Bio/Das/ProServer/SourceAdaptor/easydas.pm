#########
# Author:        Bernat Gel
# Maintainer:    Bernat Gel
# Created:       2009-10-19
#
# Builds DAS features from the easyDAS mysql schema
# 
#
#
package Bio::Das::ProServer::SourceAdaptor::easydas;
use strict;
use warnings;
use base qw(Bio::Das::ProServer::SourceAdaptor);
use Readonly;

use Data::Dumper;

sub capabilities {
  return {
	  features     => '1.1',
	  stylesheet   => '1.1',
	  types	       => '1.1'
	 };
}

#the SourceAdaptor has taken care of the core initializaion. Get some more information specific to easyDAS
sub init {
  my ($self) = @_;
  my $dsn = $self->dsn;
  $self->{'server_name'} = $self->{'config'}->{'easydas_server_name'}; #WARNING: Will it be replaced when necessary??? Will it be necessary?
  print "Init in easydas input adaptor with dsn: $dsn  and server_name: ".$self->{'server_name'}."\n";

  #get the user name associated with server name
  my $uname = $self->server_name_to_user_name($self->server_name);
  #print qq(The username associated with ).$self->server_name.qq( is: $uname\n);



  #Fetch the extended info for the source
  my $query = qq(SELECT * FROM `easydas`.`Sources`
                 WHERE  name = '$dsn' AND `user_name` = '$uname');
  my $sources = $self->transport->query($query);
  if(length @{$sources} < 1) {
    print qq(Unknown source: $dsn);
  }
  my $s = $sources->[0];
  #use Data::Dumper;  print "input adaptor for source: ".Dumper($s);
  #and assign it to the source adaptor (only for the defined fields)
  $s->{'title'} && ($self->{'title'} = $s->{'title'});
  $s->{'description'} && ($self->{'description'} = $s->{'description'});
  $s->{'maintainer'} && ($self->{'maintainer'} = $s->{'maintainer'});
  $s->{'doc_href'} && ($self->{'doc_href'} = $s->{'doc_href'});
  $s->{'version'} && ($self->{'version'} = $s->{'version'});
  #TODO: Should change it to get the user_name from the users table
  $uname && ($self->{'user_name'} = $uname);
#print qq(Coordinates System from DB: ).$s->{'coordinates_system_id'}.qq(\n);
  $s->{'coordinates_system_id'} && ($self->{'coordinates'} = {$s->{'coordinates_system_id'} => "1:0,1"});
  
  #create a type info cache
  $self->{'types'} = {};
  #create a segment id cache
  $self->{'segmentsByName'} = {};
}

sub types {
  my ($self) = @_;
  return $self->{'types'};
}

sub segmentsByName {
  my ($self) = @_;
  return $self->{'segmentsByName'};
}

sub server_name {
  my ($self) = @_;
  return $self->{'server_name'};
}

#The source_url includes the server_name in the path so different users can have the same source names
sub source_url {
  my $self = shift;
  #return $self->server_url().q(/das/).$self->dsn();  #use the standard one ATM...
  return $self->server_url().q(/).$self->{'server_name'}.q(/das/).$self->dsn();  #assumptions on the server addres are made...
}

sub user_name {
  my ($self) = @_;
  return $self->{'user_name'};
}

sub server_name_to_user_name {
  my ($self, $server_name) = @_;
######OOOOOOOOOOO      AMB ELS ANONYMOUS AIXÔ NO ES CRIDAAA!! PQ?
  print "Converting server_name ($server_name) to user_name: **"; # if($self->debug);
#TODO: Add caching? would it simply be returning $self->{'user_name'} is defined?
  if($server_name) { 
	  if($server_name eq 'anonymous') {
		$self->{'user_name'} = 'anonymous';
	  } else {
	  	#Fetch the extended info for the source
	  	my $query = qq(SELECT login FROM `easydas`.`Users`
                 WHERE  `server_name` = ').$self->{'server_name'}.qq(');
	  	my $unames = $self->transport->query($query);
	  	if(length @{$unames} < 1) {
	    		print qq(Unknown user: ).$self->{'server_name'}.qq(\n);
	  	}
	  	my $uname = $unames->[0];
	  	$self->{'user_name'} = $uname->{'login'};
	}
  }
  print $self->{'user_name'}."**\n"; # if($self->debug);
  return $self->{'user_name'};
}

#buils an array of features containing all the features asked for by the query
sub build_features {
  my ($self, $params) = @_;

  my $dsn = $self->dsn;
  my $server_name = $self->{'server_name'};

  print "In build features for $dsn from $server_name\n";
  #TODO: Implement "feature_by_id"
  my $segment =  $params->{'segment'};
  my $start =  $params->{'start'};
  my $end =  $params->{'end'};
  my $types =  $params->{'types'};
  my $categories =  $params->{'categories'};
  my $maxbins =  $params->{'maxbins'};
 
  #TODO: implement type and categories filtering in the DB query
  #TODO: implement maxbins support

  #If a segment is specified, get its id using its name
  my $seg_info;
  my $seg_id;
  if($segment && $segment ne q()) {
    $seg_info = $self->get_segment_by_name($segment);
    $seg_id = $seg_info->{'id'};
  }
  if(!$seg_id) {
      print "Returning with no features because no segment with segment name $segment was found\n";
      return ()
  };

  my $where = '1 ';
 
  $where .= qq( AND `segment_id` = '$seg_id');
  $where .= qq( AND `start` <= '$end' AND `end` >= '$start') if(defined $start && $start ne q() && defined $end && $end ne q());
  
  my $query = qq(SELECT * FROM `easydas`.`).$self->features_table_name($server_name, $dsn).qq(`
                 WHERE  $where
                 ORDER BY `start`);

  #print "Using query: $query\n";
  
  my @features;
  for ( @{$self->transport->query($query)} ) {
    #print '.';
    my $f = {
	#'segment'	=> $_               # segment ID (if not provided)
	'id'		=> $_->{'feature_id'},               # feature ID
	'label'		=> $_->{'feature_label'},               # feature text label
	'start'         => $_->{'start'},               # feature start position
	'end'           => $_->{'end'},               # feature end position
	'ori'           => $_->{'orientation'},               # feature strand
	'phase'         => $_->{'phase'},               # feature phase
	'score'		=> $_->{'score'},
	'type'		=> $_->{'type_id'}
	};
    #add the type info if available
    my $type = $self->get_type_info($_->{'type_id'});
    if(defined $type) {
      $f->{'type_cvid'} = $type->{'cvId'};
      $f->{'typetxt'} = $type->{'label'};
      $f->{'typescategory'} = $type->{'category'};
      $f->{'typereference'} = $type->{'reference'};
    }
    #add links if available
    my $links = $self->get_links($_->{'id'});
    my @links_href;
    my @links_text;
    if($links) {
      for my $l (@{$links})  {
	push @links_href, $l->{'href'};
	push @links_text, $l->{'label'};
      }
      $f->{'link'} = \@links_href;
      $f->{'linktxt'} = \@links_text;
    }
    #Notes
    my $note = $self->get_notes($_->{'id'});
    my @notes;
    for my $n (@{$note}) {
      push @notes, $n->{'text'};
    }
      
    $f->{'note'} = \@notes;
    #and store the feature
    push @features, $f;
 #typesubparts                  => $               # feature has subparts
 #typesuperparts                => $               # feature has superparts
 #method                        => $               # annotation method ID
 #method_cvid                   => $               # annotation method controlled vocabulary ID
 #method_label                  => $               # annotation method text label
 #note                          => $ or [$,$,$...] # feature text note
  }
  #print "Returning ".scalar @features. " features\n";
  
  return @features;
}

sub get_type_info {
  my ($self, $type) = @_;
  if(!$self->types->{$type}) {
    my $table = $self->types_table_name($self->server_name, $self->dsn);
    my $query = qq(SELECT * FROM `easydas`.`$table`
                 WHERE  `id` = '$type');
    $self->types->{$type} = @{$self->transport->query($query)}[0];
  }
  return $self->types->{$type}
}

sub get_links {
  my ($self, $f_id) = @_;

  my $table = $self->links_table_name($self->server_name, $self->dsn);
  my $query = qq(SELECT `href`, `label` FROM `easydas`.`$table` WHERE  `feat_id` = '$f_id');
  return $self->transport->query($query);
}

sub get_notes {
  my ($self, $f_id) = @_;

  my $table = $self->notes_table_name($self->server_name, $self->dsn);
  my $query = qq(SELECT `text` FROM `easydas`.`$table` WHERE  `feat_id` = '$f_id');
  return $self->transport->query($query);
}

sub get_segment_by_name {
  my ($self, $seg_name) = @_;

  if(!$self->segmentsByName->{$seg_name}) {
    my $table = $self->segments_table_name($self->server_name, $self->dsn);
    my $query = qq(SELECT * FROM `easydas`.`$table`
                 WHERE  `entry_point` = '$seg_name' LIMIT 1);
    $self->segmentsByName->{$seg_name} = @{$self->transport->query($query)}[0];
  }
  return $self->segmentsByName->{$seg_name};
}

sub known_segments {
  my ($self) = @_;
  
  if(!$self->{'known_segments'}) {
    my $table = $self->segments_table_name($self->server_name, $self->dsn);
    my $query = qq(SELECT `entry_point` FROM `easydas`.`$table`);
    my @ks;
    for ( @{$self->transport->query($query)} ) {
      push @ks, $_->{'entry_point'};
    }
    $self->{'known_segments'} = \@ks;
  }
  return @{$self->{'known_segments'}};
}

sub features_table_name {
  my ($self, $uname, $source) = @_;
  return "$uname#$source#Features";
}

sub types_table_name {
  my ($self, $uname, $source) = @_;
  return "$uname#$source#Types";
}


sub segments_table_name {
  my ($self, $uname, $source) = @_;
  return "$uname#$source#Segments";
}

sub links_table_name {
  my ($self, $uname, $source) = @_;
  return "$uname#$source#Links";
}

sub notes_table_name {
  my ($self, $uname, $source) = @_;
  return "$uname#$source#Notes";
}

#buils an array of types containing all the features asked for by the query
sub build_types {
  my ($self, $params) = @_;

  my $dsn = $self->dsn;
  my $server_name = $self->{'server_name'};

  print "In build types for $dsn from $server_name\n";
  #TODO: Implement "feature_by_id"
  my $segment =  $params->{'segment'};
  my $start =  $params->{'start'};
  my $end =  $params->{'end'};
  my $types =  $params->{'types'};
  
  
  my $where = "WHERE 1 ";
  
  $where .= qq( AND segment_id = '$segment') if($segment);
  $where .= qq( AND start <= '$end' AND end >= '$start') if(defined $start && $start ne q() && defined $end && $end ne q());
  
  my $query = qq(SELECT type_id, COUNT( * ) FROM `).$self->features_table_name($server_name, $dsn).qq(`
		$where  
		GROUP BY type_id
	      );

  #print "Types. Using counts query: $query\n";
    
  my @types;
  for ( @{$self->transport->query($query)} ) {
    #print "*";
    #print "Type \$_ is: ".Dumper($_);

    my $type = $self->get_type_info($_->{'type_id'}, $server_name, $dsn);
    #print "and type_info is: ".Dumper($type)."/n";
    if(defined $type) {
      push @types, {
	'type'		=> $type->{'id'},
	'category'	=> $type->{'category'},
	'description'	=> $type->{'label'},
	'type_cvid'	=> $type->{'cvId'},
	'reference'	=> $type->{'reference'},
	'count'		=> $_->{'COUNT( * )'}
      };
      #print "So far types is: ".Dumper(@types);
    }
  }
      
  return @types;
}




1;


__END__

=head1 NAME

Bio::Das::ProServer::SourceAdaptor::grouped_db

=head1 VERSION

$LastChangedRevision: 585 $

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 capabilities

=head2 build_features

=head2 build_types

=head2 build_entry_points

=head2 segment_version

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

Bio::Das::ProServer::SourceAdaptor

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

$Author: Roger Pettett$

=head1 LICENSE AND COPYRIGHT

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
