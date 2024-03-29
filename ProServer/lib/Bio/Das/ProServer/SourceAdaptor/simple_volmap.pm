#########
# Author: $andyjenkinson$
# Last Modified: $Date: 2008-09-21 19:23:26 +0100 (Sun, 21 Sep 2008) $
# $Id: simple_volmap.pm 524 2008-09-21 18:23:26Z andyjenkinson $
# $HeadURL: https://proserver.svn.sourceforge.net/svnroot/proserver/branches/1.6-spec/lib/Bio/Das/ProServer/SourceAdaptor/simple_volmap.pm $
#
package Bio::Das::ProServer::SourceAdaptor::simple_volmap;
use strict;
use warnings;
use base qw(Bio::Das::ProServer::SourceAdaptor);

our $VERSION = do { my ($v) = (q$Revision: 524 $ =~ /\d+/mxg); $v; };

sub init {
  my $self = shift;
  $self->{capabilities} = { map { $_ => '1.0' } qw(volmap entry_points) };
  return;
}

sub length { ## no critic
  my ($self, $segment) = @_;
  return $self->transport->query("field0 = $segment")->[0]->[1];
}

sub known_segments {
  my $self = shift;
  return  map { $_->[0] } @{ $self->transport->query('field0 like .*') };
}

sub build_volmap {
  my ($self, $segment) = @_;
  my $row    = $self->transport->query("field0 = $segment")->[0];
  my $volmap = {};

  for (qw(id _tmp class type version link linktxt)) {
    $volmap->{$_} = shift @{$row};
  }

  $volmap->{note} = [@{$row}];
  return $volmap;
}

1;
__END__

=head1 NAME

  Bio::Das::ProServer::SourceAdaptor::simple_volmap

=head1 VERSION

$Revision: 524 $

=head1 AUTHOR

  Andy Jenkinson <andy.jenkinson@ebi.ac.uk>

=head1 SYNOPSIS

  Volume map for Vol01:
  <host>/das/<source>/volmap?query=volumeID


=head1 DESCRIPTION

  Serves up volume map DAS responses, using a file-based transport.

=head1 SUBROUTINES/METHODS

=head2 build_volmap

=head2 init

=head2 known_segments

=head2 length

=head1 CONFIGURATION AND ENVIRONMENT

  [simple_volmap]
  adaptor               = simple_volmap
  state                 = on
  transport             = file
  filename              = /data/volmap.txt
  coordinates           = MyCoordSys -> Vol01

  Tab-separated file formats:

  --volmap.txt--
  id	length	class	type	version	link	linktxt

=head1 DEPENDENCIES

=over

=item L<Bio::Das::ProServer::SourceAdaptor>

=back

=head1 DIAGNOSTICS

=head1 INCOMPATIBILITIES

None reported

=head1 BUGS AND LIMITATIONS

None reported

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2007 EMBL-EBI

=cut
