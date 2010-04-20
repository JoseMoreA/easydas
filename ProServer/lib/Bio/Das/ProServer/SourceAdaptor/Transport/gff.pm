#########
# Author:        Bernat Gel
# Maintainer:    Bernat Gel
# Created:       2003-05-20
# Last Modified: 2003-05-27
#
# Transport layer for file-based storage (slow)
#
package Bio::Das::ProServer::SourceAdaptor::Transport::gff;

use strict; 
use warnings;

use File::stat;
use English qw(-no_match_vars);
use Carp;

use Data::Dumper;

use base qw(Bio::Das::ProServer::SourceAdaptor::Transport::generic);

our $VERSION  = do { my ($v) = (q$Revision: 567 $ =~ /\d+/mxg); $v; };

sub init {
  my ($self, $defs) = @_;
  if($self->{'config'}->{'data_path'}) {
    $self->{'data_path'} = $self->{'config'}->{'data_path'};
  } else {
    $self->{'data_path'} = ".";
    croak("The 'data_path' INI attribute is not set!");
  }
  $self->{'filename'} = $self->{'data_path'}.'/'.$self->{'dsn'};
  print "Bernat (T::GFF-init): initializing transport. filename=".$self->{'filename'}."\n"; 
}

sub _fh {
  my $self = shift;

  if(!$self->{'fh'}) {
    my $fn = $self->{'filename'} || $self->config->{'filename'};
    open $self->{'fh'}, q(<), $fn or croak qq(Could not open $fn);
  }
  return $self->{'fh'};
}

#Returns name, description, mantainer
sub getConfigInfo {
    my ($self, $defs) = @_;
    
    #TODO: Read them from the file!!!
    return ($defs->{'dsn'}, "Features in the gff file ".$defs->{'dsn'}, "Bernat Gel");
}


sub query {
  my ($self, $query) = @_;
  print "Bernat (T::GFF-query): iniciem amb query=".Dumper($query)."\n";

#Query has:
#   'query_type'=> 
#   'segment'   => $opts->{'segment'},
#   'start'     => $opts->{'start'},
#   'end'       => $opts->{'end'},
#   'types'     => $opts->{'types'},
#   'maxbins'   => $opts->{'maxbins'}

  
  my $fh    = $self->_fh();
  seek $fh, 0, 0;

  my $wanted_type;
  if($query->{'types'}) {
    for (@{$query->{'types'}}) { $wanted_type->{$_} = 1 }
  }

  my $ref = [];
  LINE: while(my $line = <$fh>) {
    chomp $line;
    $line || next;
    next LINE if($line =~ /^#/);
    my @parts = split /\t/mx, $line;

    #Check if it's a wanted feature
    print "Bernat (T:GFF-query): Comparing segments: wanted->".$query->{'segment'}." vs has-> ".$parts[0]."\n";
    next LINE if($query->{'segment'} && $query->{'segment'} ne $parts[0]);
    print "Bernat (T:GFF-query): Segments OK. Testing Position.\n";
    next LINE if(($query->{'start'} && $query->{'start'} > $parts[4]) || ($query->{'end'} && $query->{'end'} < $parts[3]));
    print "Bernat (T:GFF-query): Position OK. Testing Types: ".$parts[2]." is in ".Dumper($wanted_type)."\n";
    #next LINE if($query->{'types'} && !$wanted_type->{$parts[2]});
    
    
 
     my %feature = (
  	type     => $parts[2],
  	method   => $parts[1],
  	segment  => $parts[0], #$_->[0],
 	id       => $parts[2].$parts[3], #$_->[3],
        start    => $parts[3],
        end     => $parts[4],
  	group_id => "group", #$_->[4],
  	note     => "a nota blablabla", #$_->[1],
 	link     => "a link to somewhere" #$baseurl.$_->[2],
        );
 

    push @{$ref}, \%feature;

  }
  return $ref;
  
}
#   foreach (1 .. 10) {
#      print "Bernat (T::GFF-query): afegint feature $_\n";
#      my %feature = (
#  	type     => "a type",
#  	method   => "a method",
#  	segment  => "1", #$_->[0],
#  	id       => "f$_", #$_->[3],
#  	group_id => "group", #$_->[4],
#  	note     => "a nota blablabla", #$_->[1],
#  	link     => "a link to somewhere" #$baseurl.$_->[2],
#         );
#      push @features, \%feature;
# 
# #      push @features, map {
# #         {
# #         };
# #     }
#   }
#   print "Bernat (T::GFF-query): Features are ".Dumper(@features)."\n";
#   return \@features;
# }
  
#   $self->{'debug'} and carp "Transport::file::query was $query\n";
#   my @queries = ();
#   for (split /\s(?:AND|&&)\s/i, $query) {
#     my ($field, $cmp, $value) = split /\s/mx, $_;
#     $field   =~ s/^field//mx;
#     $value   =~ s/^[\"\'](.*?)[\"\']$/$1/mx;
#     $value   =~ s/%/.*?/mxg;
#     $cmp     = lc $cmp;
# 
#     if ($cmp eq '=') {
#       push @queries, sub { $_[$field] eq $value };
#     } elsif ($cmp eq 'lceq') {
#       push @queries, sub { lc $_[$field] eq lc $value };
#     } elsif ($cmp eq 'like') {
#       push @queries, sub { $_[$field] =~ /^$value$/mxi };
#     } elsif ($cmp eq '>=') {
#       push @queries, sub { return $_[$field] >= $value ? 1 : 0 };
#     } elsif ($cmp eq '>') {
#       push @queries, sub { $_[$field] > $value };
#     } elsif ($cmp eq '<=') {
#       push @queries, sub { return $_[$field] <= $value ? 1 : 0 };
#     } elsif ($cmp eq '<') {
#       push @queries, sub { $_[$field] < $value };
#     } else {
#       carp "Unrecognised query: $_\n";
#     }
#   }

#   return $self->config->{'cache'} && $self->config->{'cache'} ne 'no' ?
#     $self->_query_mem(@queries) :
#     $self->_query_fh(@queries);


sub get_types {
  my ($self, $query) = @_;
  my $fh = $self->_fh(); #Check if the file is open
  seek $fh, 0, 0; #move to the beginning of the file

  my $line;
  while($line = readline($self->{'fh'})) {
	last unless $line =~ /^\#/;
  }

  my $types = {};
  #line has the first non-header line
  do {
	chomp $line;
	my ($seqname, $source, $primary, $start, 
      	$end, $score, $strand, $frame, @attribs) = split(/\t+/, $line);
        my $attribs = join '', @attribs;  # just in case the rule 
                                     # against tab characters has been broken
	#count the types
	if($types->{$primary}->{'count'}) { #if already found one of that type, increment
		$types->{$primary}->{'count'}++
	} else { #if not, notify we've got one
		$types->{$primary}->{'count'}=1
	}
	#($types->{$primary}->{'count'}?$types->{$primary}->{'count'}++:$types->{$primary}->{'count'}=1;
  } while($line = readline($self->{'fh'}));

  
  print "TYPES: ".Dumper($types)."\n";

  return $types;
}

sub get_sequence {
    my ($self, $query) = @_;
    my $fh = $self->_fh(); #Check if the file is open
    seek $fh, 0, 0; #move to the beginning of the file

    #TODO: CAL DEFINIR QUE FER EN TOTS ELS CASOS I VEURE QUE PASSA SI LES DIVERSES SEQUENCIES ESTAN EN DIVERSOS ARXIUS...

    my $start = $query->{'start'};
    my $end = $query->{'end'};
    my $remaining = $end - $start +1;
    print "Bernat (T:GFF-get_sequence): Demanant la sequencia entre $start i $end ($remaining bases)\n";

    my $line;
    my $filename;
    while($line = readline($self->{'fh'})) {
        if($line =~ /^#sequence/) {
            print "Bernat (T:GFF-get_sequence): comment line $line\n";
            my @parts = split(' ', $line);
            print "parts: ".Dumper(@parts)."\n";
            $filename = $parts[3];
            print "Bernat (T:GFF-get_sequence): Filename is $filename\n";
        }
        last unless $line =~ /^\#/;
    }
    
    $filename = $self->{'data_path'}.$filename;
    #$filename = "~alggen/cgi-bin/search/conrepp/tmp/".$filename;
    print "Bernat (T:GFF-get_sequence): Complete filename is $filename\n";
    open SEQ, q(<), $filename or croak qq(Could not open $filename);

    while($line = readline(SEQ)) {
        last unless $line =~ /^>/;
    }
    my $counter = 0;
    my $seq = "";
    while($line = readline(SEQ)) {
        print "Bernat (T:GFF-get_sequence): Read line is $line\n";
        if(((length $line) + $counter) < $start) {
            $counter += length $line;
            next;
        }
        my $sdif = $start-$counter;
        $sdif = 0 if($sdif<0);
        $seq .= substr($line,$sdif,$remaining);
        print "Bernat (T:GFF-get_sequence): new seq is: $seq\n";
        $remaining = $remaining - ((length $line) - $sdif);
        last if($remaining<0);
        print "Bernat (T:GFF-get_sequence): new seq has length : ".length($seq)." and remaining is $remaining\n";
    }
    return {
        'seq'     => $seq,
        'version' => 1, # can also be specified with the segment_version method
        'moltype' => 'dna'
    };

}


sub _query_mem {
  my ( $self, @predicates ) = @_;
  $self->{'debug'} && carp "Querying against memory cache";
  my $ref = [];
  LINE: for my $parts (@{ $self->_contents() }) {
    for my $predicate (@predicates) {
      &$predicate( @{ $parts } ) || next LINE;
    }

    push @{$ref}, $parts;
    if($self->config->{'unique'}) {
      last;
    }
  }
  return $ref;
}

sub _query_fh {
  my ( $self, @predicates ) = @_;

  $self->{'debug'} && carp "Querying against file";
  local $RS = "\n";
  my $fh    = $self->_fh();
  seek $fh, 0, 0;

  my $ref = [];
  LINE: while(my $line = <$fh>) {
    chomp $line;
    $line || next;
    my @parts = split /\t/mx, $line;

    for my $predicate (@predicates) {
      &$predicate( @parts ) || next LINE;
    }

    push @{$ref}, \@parts;
    if($self->config->{'unique'}) {
      last;
    }
  }
  return $ref;
}

sub _contents {
  my $self = shift;

  if (!exists $self->{'_contents'}) {
    local $RS = "\n";
    my $fh    = $self->_fh();
    seek $fh, 0, 0;

    my $ref = [];
    while(my $line = <$fh>) {
      chomp $line;
      $line || next;
      my @parts = split /\t/mx, $line;
      push @{$ref}, \@parts;
    }
    $self->{'_contents'} = $ref;
    $self->{'_modified'} = stat($fh)->mtime; # Set the modified time
  }

  return $self->{'_contents'};
}

sub last_modified {
  my $self = shift;
  # If the file was cached, use the time from when it was loaded
  #if ($self->{'_modified'}) {
  #  return $self->{'_modified'};
  #}
  # Otherwise check it explicitly
  return stat($self->_fh())->mtime;
}

sub DESTROY {
  my $self = shift;
  if($self->{'fh'}) {
    close $self->{'fh'} or carp 'Error closing fh';
  }
  return;
}

1;
__END__

=head1 NAME

Bio::Das::ProServer::SourceAdaptor::Transport::file

=head1 VERSION

$Revision: 567 $

=head1 SYNOPSIS

=head1 DESCRIPTION

A simple data transport for tab-separated files. Access is via the 'query' method.
Expects a tab-separated file with no header line.

Can optionally cache the file contents upon first usage. This may improve
subsequence response speed at the expense of memory footprint.

=head1 SUBROUTINES/METHODS

=head2 query - Execute a basic query against a text file

 Queries are of the form:

 $filetransport->query(qq(field1 = 'value'));
 $filetransport->query(qq(field1 lceq 'value'));
 $filetransport->query(qq(field3 like '%value%'));
 $filetransport->query(qq(field0 = 'value' && field1 = 'value'));
 $filetransport->query(qq(field0 = 'value' and field1 = 'value'));
 $filetransport->query(qq(field0 = 'value' and field1 = 'value' and field2 = 'value'));

 "OR" compound queries not (yet) supported

=head2 last_modified - machine time of last data change

  $dbitransport->last_modified();

=head2 DESTROY - object destructor - disconnect filehandle

  Generally not directly invoked, but if you really want to - 

  $filetransport->DESTROY();

=head1 DIAGNOSTICS

Run ProServer with the -debug flag.

=head1 CONFIGURATION AND ENVIRONMENT

Configured as part of each source's ProServer 2 INI file:

  [myfile]
  ... source configuration ...
  transport = file
  filename  = /data/features.tsv
  unique    = 1 # optional
  cache     = 1 # optional

=head1 DEPENDENCIES

=over

=item L<File::stat>

=item L<Bio::Das::ProServer::SourceAdaptor::Transport::generic>

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

Only AND compound queries are supported.

=head1 AUTHOR

Roger Pettett <rmp@sanger.ac.uk> and Andy Jenkinson <aj@ebi.ac.uk>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008 The Sanger Institute and EMBL-EBI

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  See DISCLAIMER.txt for
disclaimers of warranty.

=cut
