#########
# Author:        bernat gel
# Created:       2003-05-20
#
#
#  This is a simple script to cleanly remove sources from the easyDAS database.


use strict;
use warnings;

use Carp;
use Data::Dumper;
use DBI;


#Get the info from the command line


#my $base_name = $ARGV[0]; #'#canis-mirna#';
#print "base_name to remove: $base_name\n";

my @base_names = ('user#test#','user#cnv_full#','user#cnv#','rajido#testRafa05#','rajido#test07#',
	'rajido#test06#','rajido#CGH#','bernat_oid#test#','bernat_oid#microrna#','bernat3#microrna#',
'bernat2#microrna#','bernat#test_bla#','bernat#test17#','bernat#test16#','bernat#test15#','bernat#test14#',
'bernat#test13#', 'bernat#test12#', 'bernat#test11#', 'bernat#test10#',
'bernat#micros#','bernat#microrna_notes#','bernat#microrna_bla#','bernat#exp-prot-expression#','#tets_micros#'); 
			

#Connect to the DB
my $dbh = DBI->connect("DBI:mysql:database=easydas;host=mysql-easydas:4236",'admin','l2fKWd3D', 
			{RaiseError => 1, AutoCommit=>1});

foreach (@base_names) {
	&remove($_);
}
	


    

#try to remove the tables
sub remove {
	my $base_name = shift;
	print "Removing $base_name \n";	
	
	my $remove = $dbh->prepare('DROP TABLE `'.$base_name.'Notes'.'`');
	eval{$remove->execute()};

	$remove = $dbh->prepare('DROP TABLE `'.$base_name.'Links'.'`');
	eval{$remove->execute()};

	$remove = $dbh->prepare('DROP TABLE `'.$base_name.'Types'.'`');
	eval{$remove->execute()};

	$remove = $dbh->prepare('DROP TABLE `'.$base_name.'Methods'.'`');
	eval{$remove->execute()};

	$remove = $dbh->prepare('DROP TABLE `'.$base_name.'Features'.'`');
	eval{$remove->execute()};

	$remove = $dbh->prepare('DROP TABLE `'.$base_name.'Segments'.'`');
	eval{$remove->execute()};

	print "Done\n";
}

#my $sources_query = $self->dbh->prepare_cached('DELETE FROM `easydas`.`Sources` WHERE `Sources`.`id` = ? LIMIT 1');
#  $sources_query->execute($source_id);
#  if($sources_query->err()) {
#    die qq({'error': {'id': 'db_error', 'msg': 'There was an error when removing the source "$source_id" from the Sources #table. ).$sources_query->err().qq('}});
#  }
#  return 1;
#}

exit;

1;
