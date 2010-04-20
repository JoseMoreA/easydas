#########
# Author:        Bernat Gel
# Maintainer:    $Author: bernatgel $
# Created:       2009-05-20
# Source:        $Source: $
# $HeadURL: https://proserver.svn.sf.net/svnroot/proserver/trunk/lib/Bio/Das/ProServer/SourceHydra/file.pm $
#
# 
#
package Bio::Das::ProServer::SourceHydra::genexp;
use strict;
use warnings;
use English qw(-no_match_vars);
use Carp;
use base qw(Bio::Das::ProServer::SourceHydra);
use Readonly;
use Data::Dumper;

our $VERSION       = do { my ($v) = (q$Revision: 506 $ =~ /\d+/mxg); $v; };
Readonly::Scalar our $CACHE_TIMEOUT => 5;


#########
# the purpose of this module:
#
sub sources {
  my ($self)    = @_;
  my $hydraname = $self->{'dsn'};
  my $data_path       = $self->config->{'data_path'};
  my $now = time;

  print "I'm hydra. My transport is: ".$self->transport."\n";
  
  #########
  # flush the cache *at most* once every $CACHE_TIMEOUT
  #
  if($now > ($self->{'_sourcecache_timestamp'} || 0)+$CACHE_TIMEOUT) {
    $self->{'debug'} and carp qq(Flushing sources cache for $hydraname);
    delete $self->{'_sources'};
    $self->{'_sourcecache_timestamp'} = $now;
  }

  #scan the data folder to get the source files
  if(!exists $self->{'_sources'}) {
    $self->{'_sources'} = [];
    eval {
      $self->{'debug'} and carp qq(Fetching sources from $data_path);

      opendir(DIR, $data_path);
      my @files = grep { /\.gff$/ } readdir(DIR);
      closedir(DIR);
      $self->{'debug'} and carp "Files in dir: ".Dumper(@files);
      my @f;
      foreach (@files) {
        #tractar-lo, comprovarr dates, etc...
        push(@f, $_);
      }
      $self->{'_sources'} = \@f; #['test1', 'test2', 'test3']; #[map { $_->[0] } @{$self->transport()->dbh()->selectall_arrayref($sql)}];
      $self->{'debug'} and carp "Files in dir: ".Dumper($self->{'_sources'});
      $self->{'debug'} and carp qq(@{[scalar @{$self->{'_sources'}}]} sources found);
      1;
    } or do {
      carp "Error scanning data folder: $EVAL_ERROR";
      delete $self->{'_sources'};
    };
  }

  return @{$self->{'_sources'} || []};

}

1;
__END__

=head1 NAME

Bio::Das::ProServer::SourceHydra::file - A file based implementation of B::D::P::SourceHydra

=head1 VERSION

$Revision: 1 $

=head1 AUTHOR

Bernat Gel

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 UPC

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  See DISCLAIMER.txt for
disclaimers of warranty.

=head1 DESCRIPTION

Implementation of a source hydra based on files. It creates s new source for every gff file found on a given data_path folder.

=head1 SYNOPSIS

  my $fileHydra = Bio::Das::ProServer::SourceHydra::file->new( ... );
  my @sources  = $fileHydra->sources();

=head1 SUBROUTINES/METHODS

=head2 sources : File sources

  Scans a preconfigured folder to find gff files. For every file a new source is returned using the name of the file as the source name.

  This routine caches results for $CACHE_TIMEOUT seconds.

=head1 DIAGNOSTICS

Run ProServer with the -debug flag.

=head1 CONFIGURATION AND ENVIRONMENT

  [mysimplehydra]
  adaptor   = file           # SourceAdaptor to clone
  hydra     = file               # Hydra implementation to use
  transport = file
  data_path = ./path_to_the_data

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=cut
