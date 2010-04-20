#########
# Author:        Bernat Gel
# Maintainer:    $Author: bernatgel $
# Created:       2009-10-21
#
# DBI-driven sourceadaptor broker. Adapted from sql for the easyDAS project. It takes the easydas_server_name property when returning the sources
# The caching system also takes the user into account.

package Bio::Das::ProServer::SourceHydra::easydas;
use strict;
use warnings;
use English qw(-no_match_vars);
use Carp;
use base qw(Bio::Das::ProServer::SourceHydra::dbi);
use Readonly;

our $VERSION       = do { my ($v) = (q$Revision: 506 $ =~ /\d+/mxg); $v; };
Readonly::Scalar our $CACHE_TIMEOUT => 30;

#########
# the purpose of this module:
#
sub sources {
  my ($self)    = @_;
  my $hydraname = $self->{'dsn'};
  my $now       = time;

  my $server_name = $self->{'easydas_server_name'};
    
  my $sql = "SELECT name FROM `easydas`.`Sources` S, `easydas`.`Users` U WHERE S.`user_name` = U.`login` and U.`server_name`='$server_name'"; 
      #OLD ONE: "SELECT name FROM `easydas`.`Sources` WHERE `user_name` = '$username'";
print "Hydra per trobar sources. SQL query: $sql\n";
  #########
  # flush the table cache *at most* once every $CACHE_TIMEOUT
  # This may need signal triggering to have immediate support
  #
  if($now > ($self->{'_sourcecache_timestamp'} || 0)+$CACHE_TIMEOUT) {
    $self->{'debug'} and carp qq(Flushing table-cache for $hydraname);
    delete $self->{'_sources'};
    $self->{'_sourcecache_timestamp'} = $now;
  }

  # Use the configured query to find the names of the sources
  if(!exists $self->{'_sources'}->{$server_name}) {
    $self->{'_sources'}->{$server_name} = [];
    eval {
      $self->{'debug'} and carp qq(Fetching sources using query: $sql);
      my $results = $self->transport()->dbh()->selectall_arrayref($sql);
      $self->{'_sources'}->{$server_name} = [map { $_->[0] } @{$results}];
use Data::Dumper; print "Sources are: ".Dumper($self->{'_sources'})."\n";
      $self->{'debug'} and carp qq(@{[scalar @{$self->{'_sources'}->{$server_name}}]} sources found);
      1;

    } or do {
      carp "Error scanning database: $EVAL_ERROR";
      delete $self->{'_sources'}->{$server_name};
    };
  } else {
      $self->{'debug'} and carp qq(Cache found. Returning cached sources for $server_name);
  }

  return @{$self->{'_sources'}->{$server_name} || []};
}

1;
__END__

=head1 NAME

Bio::Das::ProServer::SourceHydra::sql - A database-backed implementation of B::D::P::SourceHydra

=head1 VERSION

$Revision: 506 $

=head1 AUTHOR

Andy Jenkinson <andy.jenkinson@ebi.ac.uk>.

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008 EMBL-EBI

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  See DISCLAIMER.txt for
disclaimers of warranty.

=head1 DESCRIPTION

Extension of the 'dbi' hydra to allow the use of custom SQL queries to determine
the available source names.

=head1 SYNOPSIS

  my $sqlHydra = Bio::Das::ProServer::SourceHydra::sql->new( ... );
  my @sources  = $dbiHydra->sources();

=head1 SUBROUTINES/METHODS

=head2 sources : DBI sources

  Runs a preconfigured SQL statement, with the first column of each row of the
  results being the name of a DAS source.

  my @sources = $sqlhydra->sources();

  The SQL query comes from $self->config->{'query'};

  This routine caches results for $CACHE_TIMEOUT seconds.

=head1 DIAGNOSTICS

Run ProServer with the -debug flag.

=head1 CONFIGURATION AND ENVIRONMENT

  [mysimplehydra]
  adaptor   = simpledb           # SourceAdaptor to clone
  hydra     = sql                # Hydra implementation to use
  transport = dbi
  query     = select sourcename from meta_table
  dbname    = proserver
  dbhost    = mysql.example.com
  dbuser    = proserverro
  dbpass    = topsecret

=head1 DEPENDENCIES

Bio::Das::ProServer::SourceHydra::dbi

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=cut