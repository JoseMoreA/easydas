#########
# Author:        Bernat Gel
# Maintainer:    Bernat Gel
# Created:       2009-05-20
#
#
package Bio::Das::ProServer::SourceAdaptor::genexp;
use strict;
use warnings;
use base qw(Bio::Das::ProServer::SourceAdaptor);
use Carp;

use Data::Dumper;

our $VERSION = do { my ($v) = (q$Revision: 549 $ =~ /\d+/mxg); $v; };

sub init {
  my ($self, $defs) = @_;
  
  print "Initializing adaptor genexp\n";
  
  if($self->{'config'}->{'data_path'}) {
    $self->{'data_path'} = $self->{'config'}->{'data_path'};
    print "data_path is: ".$self->{'config'}->{'data_path'}."\n";
  } else {
    croak("The 'data_path' INI attribute is not set!");
  }
  #TODO: Calcular quines capabilities hi ha, si cal...
  #Mirar si hi ha sequencia, entry_points, etc...
  $self->{'capabilities'} = {
                    'features'  => '1.0',
                    'types'     => '1.0',
                    'sequence'  => '1.0',
  };


  my ($title, $description, $mantainer) = $self->transport->getConfigInfo($defs);

  $self->{'title'} = $title || $self->dsn;
  $self->{'description'} = $description || "";
  $self->{'mantainer'} = $mantainer;

  #print "CONFIG: ".Dumper($self->{'config'});
  #print "DEFS: ".Dumper($defs);
  

}

sub capabilities {
  my ($self) = @_;
  
  print "Bernat (SA::genexp): Capabilities Called\n";
  return $self->{'capabilities'};
}

sub sequence {
  my ($self, $opts) = @_;

  my $query_args = {
              'query_type'=> 'sequence',
	      'segment'   => $opts->{'segment'},
	      'start'     => $opts->{'start'},
              'end'       => $opts->{'end'}
	     };
  #de moment ho fem hardcodejant la crida al transport
  my $sequence = $self->transport->get_sequence($query_args);
  print "Bernat (SA::genexp-sequence): types=".Dumper($sequence)."\n";
 
  return $sequence;
}
sub build_types {
  my ($self, $opts) = @_;
  #de moment ho fem hardcodejant la crida al transport
  my $types = $self->transport->get_types();
  print "Bernat (SA::genexp-build_types): types=".Dumper($types)."\n";
 
  #types �s un hash de hashs. El passem a vector

  print "Bernat (genexp-build_types): types �s un ".ref($types)."\n";

   my $vtypes = [];
   while ( my ($type, $info) = each(%$types) ) {
     $info->{'type'} = $type;
     print "tractant $type: info �s un ".ref($info)." i �s ".Dumper($info)."\n";
     push @{$vtypes}, {'type'=>$type, 'count'=>$info->{'count'}, 'category'=>'cat'};
  }

  print "Bernat (SA:genexp-build_types): vtypes �s un ".ref($vtypes)." i �s ".Dumper($vtypes)."\n";
  return @{$vtypes};
}

sub build_features {
  my ($self, $opts) = @_;

  print "Bernat (SA::genexp): Build_Features in SourceAdaptor::genexp\n";


  my $baseurl = $self->config->{'baseurl'};

  my $query_args = {
              'query_type'=> 'features',
	      'segment'   => $opts->{'segment'},
	      'start'     => $opts->{'start'},
              'end'       => $opts->{'end'},
              'types'     => $opts->{'types'},
              'maxbins'   => $opts->{'maxbins'}
	     };
  print "Bernat (SA::genexp-build_features): opts=".Dumper($opts)."\n    args=".Dumper($query_args)."\n";
  my @features = @{$self->transport->query($query_args)};
  print "Bernat (SA::genexp-build_features): features=".Dumper(@features)."\n";

#   for my $query (qw(feature_query fid_query gid_query)) {
#     my $arg = $args->{$query};
#     if(!$arg) {
#       next;
#     }
#     push @features, map {
#       {
# 	type     => $self->config->{'type'},
# 	method   => $self->config->{'type'},
# 	segment  => $_->[0],
# 	id       => $_->[3],
# 	group_id => $_->[4],
# 	note     => $_->[1],
# 	link     => $baseurl.$_->[2],
#       };
#     } @{$self->transport->query(sprintf $self->config->{$query}, $arg)};
#   }

  return @features;
}

1;
__END__

=head1 NAME

Bio::Das::ProServer::SourceAdaptor::simple

=head1 VERSION

$LastChangedRevision: 549 $

=head1 SYNOPSIS

Builds das from parser genesat tab-delimited flat files of the form:

 gene.name	gene.id

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 init - Initialise capabilities for this source

  $oSourceAdaptor->init();

=head2 build_features - Return an array of features based on a query given in the config file

  my @aFeatures = $oSourceAdaptor->build_features({
                                                   'segment'    => $sSegmentId,
                                                   'start'      => $iSegmentStart, # Optional
                                                   'end'        => $iSegmentEnd,   # Optional
                                                  });
  my @aFeatures = $oSourceAdaptor->build_features({
                                                   'feature_id' => $sFeatureId,
                                                  });

  my @aFeatures = $oSourceAdaptor->build_features({
                                                   'group_id'   => $sGroupId,
                                                  });

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

 Bio::Das::ProServer::SourceAdaptor
Carp

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
