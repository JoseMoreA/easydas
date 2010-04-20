-- SQL to create the DB for easyDAS v0.1 --

--
-- Table structure for table `Sources`
--

DROP TABLE IF EXISTS `Sources`;
CREATE TABLE `Sources` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(60) NOT NULL COMMENT 'the name of the source. Unique in a per user base\n',
  `title` text COMMENT 'A title for the source',
  `description` text,
  `maintainer` tinytext,
  `user_name` varchar(255) default NULL,
  `doc_href` mediumtext,
  `version` smallint(6) default '0',
  `coordinates_system_id` varchar(255) default NULL,
  `coordinate_system_info` tinytext,
  `modification_date` datetime NOT NULL,
  `creation_date` datetime NOT NULL,
  `test_range` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Data defining the general configuration of each available source';

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
CREATE TABLE `Users` (
  `id` bigint(20) unsigned NOT NULL auto_increment,
  `login` varchar(100) NOT NULL,
  `passwd` char(32) default NULL,
  `session` char(32) default NULL,
  `session_exp` varchar(20) default NULL,
  `is_openid` tinyint(1) NOT NULL default '0' COMMENT 'This flag is true if this user is an openid user',
  `server_name` varchar(32) NOT NULL COMMENT 'The name of the DAS server associated wih the user',
  `email` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `login` (`login`),
  UNIQUE KEY `session` (`session`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

