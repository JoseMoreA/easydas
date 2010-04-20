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
my $base_name = '#canis-mirna#';

#Connect to the DB
my $dbh = DBI->connect("DBI:mysql:database=easydas;host=mysql-easydas:4236",'admin','l2fKWd3D', {RaiseError => 1, AutoCommit=>1});
    

#try to remove the tables

my $remove = $dbh->prepare('DROP TABLE `'.$base_name.'Notes'.'`');
eval{$remove->execute()};
if($remove->err()) {
      print qq(Error when removing: ).$remove->err().q(\n);
}

$remove = $dbh->prepare('DROP TABLE `'.$base_name.'Links'.'`');
eval{$remove->execute()};
if($remove->err()) {
      print qq(Error when removing: ).$remove->err().q(\n);
}

$remove = $dbh->prepare('DROP TABLE `'.$base_name.'Types'.'`');
eval{$remove->execute()};
if($remove->err()) {
      print qq(Error when removing: ).$remove->err().q(\n);
}

$remove = $dbh->prepare('DROP TABLE `'.$base_name.'Methods'.'`');
eval{$remove->execute()};
if($remove->err()) {
      print qq(Error when removing: ).$remove->err().q(\n);
}

$remove = $dbh->prepare('DROP TABLE `'.$base_name.'Features'.'`');
eval{$remove->execute()};
if($remove->err()) {
      print qq(Error when removing: ).$remove->err().q(\n);
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
