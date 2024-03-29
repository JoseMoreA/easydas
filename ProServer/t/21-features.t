use strict;
use warnings;
use Test::More tests => 4;
my $sa = SA::FeaturesStub->new();

my $expected_response = qq(<SEGMENT id="seg-1" version="1.0" start="100" stop="300">\n<FEATURE id="grp-1"><TYPE id="t2" /><METHOD id="m2" /><START>100</START><END>300</END><PART id="feat-1" /><PART id="feat-2" /></FEATURE><FEATURE id="feat-1"><TYPE id="t" /><METHOD id="m" /><START>100</START><END>200</END><PARENT id="grp-1" /></FEATURE><FEATURE id="feat-2"><TYPE id="t" /><METHOD id="m" /><START>200</START><END>300</END><PARENT id="grp-1" /></FEATURE>\n</SEGMENT>\n);
my $response = $sa->das_features({'segments' => ['seg-1:100,300']});
is_deeply($response, $expected_response, "query by segment");

$response = $sa->das_features({'features' => ['grp-1']});
is_deeply($response, $expected_response, "query by parent feature ID");

$expected_response .= qq(<SEGMENT id="seg-3" version="1.0" start="300" stop="400">\n<FEATURE id="grp-3"><TYPE id="t2" /><METHOD id="m2" /><START>300</START><END>400</END><PART id="feat-3" /></FEATURE><FEATURE id="feat-3"><TYPE id="t" /><METHOD id="m" /><START>300</START><END>400</END><PARENT id="grp-3" /></FEATURE>\n</SEGMENT>\n);
$response = $sa->das_features({'segments' => ['seg-1:100,300','seg-3:300,400']});
is_deeply($response, $expected_response, "query by multiple segments");

$expected_response = qq(<SEGMENT id="seg-1" version="1.0" start="200" stop="300">\n<FEATURE id="grp-1"><TYPE id="t2" /><METHOD id="m2" /><START>100</START><END>300</END><PART id="feat-1" /><PART id="feat-2" /></FEATURE><FEATURE id="feat-1"><TYPE id="t" /><METHOD id="m" /><START>100</START><END>200</END><PARENT id="grp-1" /></FEATURE><FEATURE id="feat-2"><TYPE id="t" /><METHOD id="m" /><START>200</START><END>300</END><PARENT id="grp-1" /></FEATURE>\n</SEGMENT>\n);
$response = $sa->das_features({'features' => ['feat-2']});
is_deeply($response, $expected_response, "query by child feature ID");



package SA::FeaturesStub;
use base qw(Bio::Das::ProServer::SourceAdaptor);

sub init {
  my $self = shift;
  $self->{'capabilities'}{'features'} = 1.1;
  $self->{'features'} = [
    {
     'segment'         => 'seg-1',
     'start'           => '100',
     'end'             => '300',
     'id'              => 'grp-1',
     'type'            => 't2',
     'method'          => 'm2',
     'part'            => ['feat-1','feat-2'],
    },
    {
     'segment'         => 'seg-3',
     'start'           => '300',
     'end'             => '400',
     'id'              => 'grp-3',
     'type'            => 't2',
     'method'          => 'm2',
     'part'            => 'feat-3',
    },
    {
     'segment'         => 'seg-1',
     'start'           => '100',
     'end'             => '200',
     'id'              => 'feat-1',
     'type'            => 't',
     'method'          => 'm',
     'parent'          => 'grp-1',
    },
    {
     'segment'         => 'seg-1',
     'start'           => '200',
     'end'             => '300',
     'id'              => 'feat-2',
     'type'            => 't',
     'method'          => 'm',
     'parent'          => ['grp-1'],
    },
    {
     'segment'         => 'seg-3',
     'start'           => '300',
     'end'             => '400',
     'id'              => 'feat-3',
     'type'            => 't',
     'method'          => 'm',
     'parent'          => ['grp-3'],
    },
   ];
}

sub build_features {
  my ($self, $params) = @_;
  my @f;
  if ($params->{'feature_id'}) {
    my ($f) = grep { $_->{'id'} eq $params->{'feature_id'} } @{ $self->{'features'} };
    if ($f) {
      @f = grep {
        $_->{'segment'} eq $f->{'segment'} &&
        $_->{'start'} <= $f->{'end'} &&
        $_->{'end'} >= $f->{'start'}
      } @{ $self->{'features'} };
    }
  } else {
    map { $_->{'segment'} eq $params->{'segment'} && push @f, $_; } @{ $self->{'features'} };
  }
  return @f;
}

1;