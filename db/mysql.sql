-- These are the database tables needed for DOMjudge.
--
-- You can pipe this file into the 'mysql' command to create the
-- database tables, but preferably use 'dj-setup-database'. Database
-- should be set externally (e.g. to 'domjudge').

/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

--
-- Table structure for table `auditlog`
--
CREATE TABLE `auditlog` (
  `logid` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `logtime` decimal(32,9) unsigned NOT NULL COMMENT 'Timestamp of the logentry',
  `cid` int(4) unsigned DEFAULT NULL COMMENT 'Contest ID associated to this entry',
  `user` varchar(255) DEFAULT NULL COMMENT 'User who performed this action',
  `datatype` varchar(25) DEFAULT NULL COMMENT 'Reference to DB table associated to this entry',
  `dataid` varchar(50) DEFAULT NULL COMMENT 'Identifier in reference table',
  `action` varchar(30) DEFAULT NULL COMMENT 'Description of action performed',
  `extrainfo` varchar(255) DEFAULT NULL COMMENT 'Optional additional description of the entry',
  PRIMARY KEY (`logid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Log of all actions performed';

--
-- Table structure for table `balloon`
--
CREATE TABLE `balloon` (
  `balloonid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `submitid` int(4) unsigned NOT NULL COMMENT 'Submission for which balloon was earned',
  `done` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Has been handed out yet?',
  PRIMARY KEY (`balloonid`),
  KEY `submitid` (`submitid`),
  CONSTRAINT `balloon_ibfk_1` FOREIGN KEY (`submitid`) REFERENCES `submission` (`submitid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Balloons to be handed out';

--
-- Table structure for table `clarification`
--
CREATE TABLE `clarification` (
  `clarid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `cid` int(4) unsigned NOT NULL COMMENT 'Contest ID',
  `respid` int(4) unsigned DEFAULT NULL COMMENT 'In reply to clarification ID',
  `submittime` decimal(32,9) unsigned NOT NULL COMMENT 'Time sent',
  `sender` int(4) unsigned DEFAULT NULL COMMENT 'Team ID, null means jury',
  `recipient` int(4) unsigned DEFAULT NULL COMMENT 'Team ID, null means to jury or to all',
  `jury_member` varchar(15) DEFAULT NULL COMMENT 'Name of jury member who answered this',
  `probid` int(4) unsigned DEFAULT NULL COMMENT 'Problem associated to this clarification',
  `body` longtext NOT NULL COMMENT 'Clarification text',
  `answered` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Has been answered by jury?',
  PRIMARY KEY  (`clarid`),
  KEY `respid` (`respid`),
  KEY `probid` (`probid`),
  KEY `cid` (`cid`),
  KEY `cid_2` (`cid`,`answered`,`submittime`),
  CONSTRAINT `clarification_ibfk_1` FOREIGN KEY (`cid`) REFERENCES `contest` (`cid`) ON DELETE CASCADE,
  CONSTRAINT `clarification_ibfk_2` FOREIGN KEY (`respid`) REFERENCES `clarification` (`clarid`) ON DELETE SET NULL,
  CONSTRAINT `clarification_ibfk_3` FOREIGN KEY (`probid`) REFERENCES `problem` (`probid`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Clarification requests by teams and responses by the jury';

--
-- Table structure for table `configuration`
--

CREATE TABLE `configuration` (
  `configid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `name` varchar(25) NOT NULL COMMENT 'Name of the configuration variable',
  `value` longtext NOT NULL COMMENT 'Content of the configuration variable (JSON encoded)',
  `type` varchar(25) DEFAULT NULL COMMENT 'Type of the value (metatype for use in the webinterface)',
  `description` varchar(255) DEFAULT NULL COMMENT 'Description for in the webinterface',
  PRIMARY KEY (`configid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Global configuration variables';

--
-- Table structure for table `contest`
--

CREATE TABLE `contest` (
  `cid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `name` varchar(255) NOT NULL COMMENT 'Descriptive name',
  `shortname` varchar(255) NOT NULL COMMENT 'Short name for this contest',
  `activatetime` decimal(32,9) unsigned NOT NULL COMMENT 'Time contest becomes visible in team/public views',
  `starttime` decimal(32,9) unsigned NOT NULL COMMENT 'Time contest starts, submissions accepted',
  `freezetime` decimal(32,9) unsigned DEFAULT NULL COMMENT 'Time scoreboard is frozen',
  `endtime` decimal(32,9) unsigned NOT NULL COMMENT 'Time after which no more submissions are accepted',
  `unfreezetime` decimal(32,9) unsigned DEFAULT NULL COMMENT 'Unfreeze a frozen scoreboard at this time',
  `deactivatetime` decimal(32,9) UNSIGNED DEFAULT NULL COMMENT 'Time contest becomes invisible in team/public views',
  `activatetime_string` varchar(20) NOT NULL COMMENT 'Authoritative absolute or relative string representation of activatetime',
  `starttime_string` varchar(20) NOT NULL COMMENT 'Authoritative absolute (only!) string representation of starttime',
  `freezetime_string` varchar(20) DEFAULT NULL COMMENT 'Authoritative absolute or relative string representation of freezetime',
  `endtime_string` varchar(20) NOT NULL COMMENT 'Authoritative absolute or relative string representation of endtime',
  `unfreezetime_string` varchar(20) DEFAULT NULL COMMENT 'Authoritative absolute or relative string representation of unfreezetrime',
  `deactivatetime_string` varchar(20) DEFAULT NULL COMMENT 'Authoritative absolute or relative string representation of deactivatetime',
  `enabled` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Whether this contest can be active',
  `process_balloons` tinyint(1) UNSIGNED DEFAULT '1' COMMENT 'Will balloons be processed for this contest?',
  `public` tinyint(1) UNSIGNED DEFAULT '1' COMMENT 'Is this contest visible for the public and non-associated teams?',
  PRIMARY KEY (`cid`),
  UNIQUE KEY `shortname` (`shortname`),
  KEY `cid` (`cid`,`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Contests that will be run with this install';

--
-- Table structure for table `contestproblem`
--

CREATE TABLE `contestproblem` (
  `cid` int(4) unsigned NOT NULL COMMENT 'Contest ID',
  `probid` int(4) unsigned NOT NULL COMMENT 'Problem ID',
  `shortname` varchar(255) NOT NULL COMMENT 'Unique problem ID within contest (string)',
  `points` int(4) unsigned NOT NULL DEFAULT '1' COMMENT 'Number of points earned by solving this problem',
  `allow_submit` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Are submissions accepted for this problem?',
  `allow_judge` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Are submissions for this problem judged?',
  `color` varchar(25) DEFAULT NULL COMMENT 'Balloon colour to display on the scoreboard',
  `lazy_eval_results` tinyint(1) unsigned DEFAULT NULL COMMENT 'Whether to do lazy evaluation for this problem; if set this overrides the global configuration setting',
  PRIMARY KEY (`cid`,`probid`),
  UNIQUE KEY `shortname` (`cid`,`shortname`),
  KEY `cid` (`cid`),
  KEY `probid` (`probid`),
  CONSTRAINT `contestproblem_ibfk_1` FOREIGN KEY (`cid`) REFERENCES `contest` (`cid`) ON DELETE CASCADE,
  CONSTRAINT `contestproblem_ibfk_2` FOREIGN KEY (`probid`) REFERENCES `problem` (`probid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Many-to-Many mapping of contests and problems';

--
-- Table structure for table `contestteam`
--

CREATE TABLE `contestteam` (
  `cid` int(4) unsigned NOT NULL COMMENT 'Contest ID',
  `teamid` int(4) unsigned NOT NULL COMMENT 'Team ID',
  PRIMARY KEY (`teamid`,`cid`),
  KEY `cid` (`cid`),
  KEY `teamid` (`teamid`),
  CONSTRAINT `contestteam_ibfk_1` FOREIGN KEY (`cid`) REFERENCES `contest` (`cid`) ON DELETE CASCADE,
  CONSTRAINT `contestteam_ibfk_2` FOREIGN KEY (`teamid`) REFERENCES `team` (`teamid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Many-to-Many mapping of contests and teams';

--
-- Table structure for table `event`
--

CREATE TABLE `event` (
  `eventid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `eventtime` decimal(32,9) unsigned NOT NULL COMMENT 'When the event occurred',
  `cid` int(4) unsigned NOT NULL COMMENT 'Contest ID',
  `clarid` int(4) unsigned DEFAULT NULL COMMENT 'Clarification ID',
  `langid` varchar(8) DEFAULT NULL COMMENT 'Language ID',
  `probid` int(4) unsigned DEFAULT NULL COMMENT 'Problem ID',
  `submitid` int(4) unsigned DEFAULT NULL COMMENT 'Submission ID',
  `judgingid` int(4) unsigned DEFAULT NULL COMMENT 'Judging ID',
  `teamid` int(4) unsigned DEFAULT NULL COMMENT 'Team ID',
  `description` longtext NOT NULL COMMENT 'Event description',
  PRIMARY KEY  (`eventid`),
  KEY `cid` (`cid`),
  KEY `clarid` (`clarid`),
  KEY `langid` (`langid`),
  KEY `probid` (`probid`),
  KEY `submitid` (`submitid`),
  KEY `judgingid` (`judgingid`),
  KEY `teamid` (`teamid`),
  CONSTRAINT `event_ibfk_1` FOREIGN KEY (`cid`) REFERENCES `contest` (`cid`) ON DELETE CASCADE,
  CONSTRAINT `event_ibfk_2` FOREIGN KEY (`clarid`) REFERENCES `clarification` (`clarid`) ON DELETE CASCADE,
  CONSTRAINT `event_ibfk_3` FOREIGN KEY (`langid`) REFERENCES `language` (`langid`) ON DELETE CASCADE,
  CONSTRAINT `event_ibfk_4` FOREIGN KEY (`probid`) REFERENCES `problem` (`probid`) ON DELETE CASCADE,
  CONSTRAINT `event_ibfk_5` FOREIGN KEY (`submitid`) REFERENCES `submission` (`submitid`) ON DELETE CASCADE,
  CONSTRAINT `event_ibfk_6` FOREIGN KEY (`judgingid`) REFERENCES `judging` (`judgingid`) ON DELETE CASCADE,
  CONSTRAINT `event_ibfk_7` FOREIGN KEY (`teamid`) REFERENCES `team` (`teamid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Log of all events during a contest';

--
-- Table structure for table `executable`
--

CREATE TABLE `executable` (
  `execid` varchar(32) NOT NULL COMMENT 'Unique ID (string)',
  `md5sum` char(32) DEFAULT NULL COMMENT 'Md5sum of zip file',
  `zipfile` longblob COMMENT 'Zip file',
  `description` varchar(255) DEFAULT NULL COMMENT 'Description of this executable',
  `type` varchar(8) NOT NULL COMMENT 'Type of executable',
  PRIMARY KEY (`execid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Compile, compare, and run script executable bundles';

--
-- Table structure for table `judgehost`
--

CREATE TABLE `judgehost` (
  `hostname` varchar(50) NOT NULL COMMENT 'Resolvable hostname of judgehost',
  `active` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Should this host take on judgings?',
  `polltime` decimal(32,9) unsigned DEFAULT NULL COMMENT 'Time of last poll by autojudger',
  `restrictionid` int(4) unsigned DEFAULT NULL COMMENT 'Optional set of restrictions for this judgehost',
  PRIMARY KEY  (`hostname`),
  KEY `restrictionid` (`restrictionid`),
  CONSTRAINT `restriction_ibfk_1` FOREIGN KEY (`restrictionid`) REFERENCES `judgehost_restriction` (`restrictionid`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Hostnames of the autojudgers';

--
-- Table structure for table `judgehost_restriction`
--

CREATE TABLE `judgehost_restriction` (
  `restrictionid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `name` varchar(255) NOT NULL COMMENT 'Descriptive name',
  `restrictions` longtext COMMENT 'JSON-encoded restrictions',
  PRIMARY KEY  (`restrictionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Restrictions for judgehosts';

--
-- Table structure for table `judging`
--

CREATE TABLE `judging` (
  `judgingid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `cid` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Contest ID',
  `submitid` int(4) unsigned NOT NULL COMMENT 'Submission ID being judged',
  `starttime` decimal(32,9) unsigned NOT NULL COMMENT 'Time judging started',
  `endtime` decimal(32,9) unsigned DEFAULT NULL COMMENT 'Time judging ended, null = still busy',
  `judgehost` varchar(50) DEFAULT NULL COMMENT 'Judgehost that performed the judging',
  `result` varchar(25) DEFAULT NULL COMMENT 'Result string as defined in config.php',
  `verified` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Result verified by jury member?',
  `jury_member` varchar(25) DEFAULT NULL COMMENT 'Name of jury member who verified this',
  `verify_comment` varchar(255) DEFAULT NULL COMMENT 'Optional additional information provided by the verifier',
  `valid` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Old judging is marked as invalid when rejudging',
  `output_compile` longblob COMMENT 'Output of the compiling the program',
  `seen` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Whether the team has seen this judging',
  `rejudgingid` int(4) unsigned DEFAULT NULL COMMENT 'Rejudging ID (if rejudge)',
  `prevjudgingid` int(4) unsigned DEFAULT NULL COMMENT 'Previous valid judging (if rejudge)',
  PRIMARY KEY  (`judgingid`),
  KEY `submitid` (`submitid`),
  KEY `judgehost` (`judgehost`),
  KEY `cid` (`cid`),
  KEY `rejudgingid` (`rejudgingid`),
  KEY `prevjudgingid` (`prevjudgingid`),
  CONSTRAINT `judging_ibfk_1` FOREIGN KEY (`cid`) REFERENCES `contest` (`cid`) ON DELETE CASCADE,
  CONSTRAINT `judging_ibfk_2` FOREIGN KEY (`submitid`) REFERENCES `submission` (`submitid`) ON DELETE CASCADE,
  CONSTRAINT `judging_ibfk_3` FOREIGN KEY (`judgehost`) REFERENCES `judgehost` (`hostname`) ON DELETE SET NULL,
  CONSTRAINT `judging_ibfk_4` FOREIGN KEY (`rejudgingid`) REFERENCES `rejudging` (`rejudgingid`) ON DELETE SET NULL,
  CONSTRAINT `judging_ibfk_5` FOREIGN KEY (`prevjudgingid`) REFERENCES `judging` (`judgingid`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Result of judging a submission';

--
-- Table structure for table `judging_run`
--

CREATE TABLE `judging_run` (
  `runid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `judgingid` int(4) unsigned NOT NULL COMMENT 'Judging ID',
  `testcaseid` int(4) unsigned NOT NULL COMMENT 'Testcase ID',
  `runresult` varchar(25) DEFAULT NULL COMMENT 'Result of this run, NULL if not finished yet',
  `runtime` float DEFAULT NULL COMMENT 'Submission running time on this testcase',
  `output_run` longblob COMMENT 'Output of running the program',
  `output_diff` longblob COMMENT 'Diffing the program output and testcase output',
  `output_error` longblob COMMENT 'Standard error output of the program',
  `output_system` longblob COMMENT 'Judging system output',
  PRIMARY KEY  (`runid`),
  UNIQUE KEY `testcaseid` (`judgingid`, `testcaseid`),
  KEY `judgingid` (`judgingid`),
  KEY `testcaseid_2` (`testcaseid`),
  CONSTRAINT `judging_run_ibfk_1` FOREIGN KEY (`testcaseid`) REFERENCES `testcase` (`testcaseid`),
  CONSTRAINT `judging_run_ibfk_2` FOREIGN KEY (`judgingid`) REFERENCES `judging` (`judgingid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Result of a testcase run within a judging';

--
-- Table structure for table `language`
--

CREATE TABLE `language` (
  `langid` varchar(8) NOT NULL COMMENT 'Unique ID (string), used for source file extension',
  `name` varchar(255) NOT NULL COMMENT 'Descriptive language name',
  `extensions` longtext COMMENT 'List of recognized extensions (JSON encoded)',
  `allow_submit` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Are submissions accepted in this language?',
  `allow_judge` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Are submissions in this language judged?',
  `time_factor` float NOT NULL DEFAULT '1' COMMENT 'Language-specific factor multiplied by problem run times',
  `compile_script` varchar(32) DEFAULT NULL COMMENT 'Script to compile source code for this language',
  PRIMARY KEY  (`langid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Programming languages in which teams can submit solutions';

--
-- Table structure for table `problem`
--

CREATE TABLE `problem` (
  `probid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `name` varchar(255) NOT NULL COMMENT 'Descriptive name',
  `timelimit` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Maximum run time for this problem',
  `memlimit` int(4) unsigned DEFAULT NULL COMMENT 'Maximum memory available (in kB) for this problem',
  `outputlimit` int(4) unsigned DEFAULT NULL COMMENT 'Maximum output size (in kB) for this problem',
  `special_run` varchar(32) DEFAULT NULL COMMENT 'Script to run submissions for this problem',
  `special_compare` varchar(32) DEFAULT NULL COMMENT 'Script to compare problem and jury output for this problem',
  `special_compare_args` varchar(255) DEFAULT NULL COMMENT 'Optional arguments to special_compare script',
  `problemtext` longblob COMMENT 'Problem text in HTML/PDF/ASCII',
  `problemtext_type` varchar(4) DEFAULT NULL COMMENT 'File type of problem text',
  PRIMARY KEY  (`probid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Problems the teams can submit solutions for';

--
-- Table structure for table `rankcache_jury`
--

CREATE TABLE `rankcache_jury` (
  `cid` int(4) unsigned NOT NULL COMMENT 'Contest ID',
  `teamid` int(4) unsigned NOT NULL COMMENT 'Team ID',
  `points` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Total correctness points',
  `totaltime` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Total time spent',
  PRIMARY KEY  (`cid`,`teamid`),
  KEY `order` (`cid`,`points`, `totaltime`) USING BTREE,
  CONSTRAINT `rankcache_jury_ibfk_1` FOREIGN KEY (`cid`) REFERENCES `contest` (`cid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Rank cache (jury version)';

--
-- Table structure for table `rankcache_public`
--

CREATE TABLE `rankcache_public` (
  `cid` int(4) unsigned NOT NULL COMMENT 'Contest ID',
  `teamid` int(4) unsigned NOT NULL COMMENT 'Team ID',
  `points` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Total correctness points',
  `totaltime` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Total time spent',
  PRIMARY KEY  (`cid`,`teamid`),
  KEY `order` (`cid`,`points`,`totaltime`) USING BTREE,
  CONSTRAINT `rankcache_public_ibfk_1` FOREIGN KEY (`cid`) REFERENCES `contest` (`cid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Rank cache (public/team version)';


--
-- Table structure for table `rejudging`
--
CREATE TABLE `rejudging` (
  `rejudgingid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `userid_start` int(4) unsigned DEFAULT NULL COMMENT 'User ID of user who started the rejudge',
  `userid_finish` int(4) unsigned DEFAULT NULL COMMENT 'User ID of user who accepted or canceled the rejudge',
  `starttime` decimal(32,9) unsigned NOT NULL COMMENT 'Time rejudging started',
  `endtime` decimal(32,9) unsigned DEFAULT NULL COMMENT 'Time rejudging ended, null = still busy',
  `reason` varchar(255) NOT NULL COMMENT 'Reason to start this rejudge',
  `valid` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Rejudging is marked as invalid if canceled',
  PRIMARY KEY  (`rejudgingid`),
  KEY `userid_start` (`userid_start`),
  KEY `userid_finish` (`userid_finish`),
  CONSTRAINT `rejudging_ibfk_1` FOREIGN KEY (`userid_start`) REFERENCES `user` (`userid`) ON DELETE SET NULL,
  CONSTRAINT `rejudging_ibfk_2` FOREIGN KEY (`userid_finish`) REFERENCES `user` (`userid`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Rejudge group';

--
-- Table structure for table `role`
--

CREATE TABLE `role` (
  `roleid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `role` varchar(25) NOT NULL COMMENT 'Role name',
  `description` varchar(255) NOT NULL COMMENT 'Description for the web interface',
  PRIMARY KEY (`roleid`),
  UNIQUE KEY `role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Possible user roles';

--
-- Table structure for table `scorecache_jury`
--

CREATE TABLE `scorecache_jury` (
  `cid` int(4) unsigned NOT NULL COMMENT 'Contest ID',
  `teamid` int(4) unsigned NOT NULL COMMENT 'Team ID',
  `probid` int(4) unsigned NOT NULL COMMENT 'Problem ID',
  `submissions` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Number of submissions made',
  `pending` int(4) NOT NULL DEFAULT '0' COMMENT 'Number of submissions pending judgement',
  `totaltime` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Total time spent',
  `is_correct` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Has there been a correct submission?',
  PRIMARY KEY  (`cid`,`teamid`,`probid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Scoreboard cache (jury version)';

--
-- Table structure for table `scorecache_public`
--

CREATE TABLE `scorecache_public` (
  `cid` int(4) unsigned NOT NULL COMMENT 'Contest ID',
  `teamid` int(4) unsigned NOT NULL COMMENT 'Team ID',
  `probid` int(4) unsigned NOT NULL COMMENT 'Problem ID',
  `submissions` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Number of submissions made',
  `pending` int(4) NOT NULL DEFAULT '0' COMMENT 'Number of submissions pending judgement',
  `totaltime` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Total time spent',
  `is_correct` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Has there been a correct submission?',
  PRIMARY KEY  (`cid`,`teamid`,`probid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Scoreboard cache (public/team version)';

--
-- Table structure for table `submission`
--

CREATE TABLE `submission` (
  `submitid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `origsubmitid` int(4) unsigned DEFAULT NULL COMMENT 'If set, specifies original submission in case of edit/resubmit',
  `cid` int(4) unsigned NOT NULL COMMENT 'Contest ID',
  `teamid` int(4) unsigned NOT NULL COMMENT 'Team ID',
  `probid` int(4) unsigned NOT NULL COMMENT 'Problem ID',
  `langid` varchar(8) NOT NULL COMMENT 'Language ID',
  `submittime` decimal(32,9) unsigned NOT NULL COMMENT 'Time submitted',
  `judgehost` varchar(50) DEFAULT NULL COMMENT 'Current/last judgehost judging this submission',
  `valid` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'If false ignore this submission in all scoreboard calculations',
  `rejudgingid` int(4) unsigned DEFAULT NULL COMMENT 'Rejudging ID (if rejudge)',
  PRIMARY KEY  (`submitid`),
  KEY `teamid` (`cid`,`teamid`),
  KEY `judgehost` (`cid`,`judgehost`),
  KEY `teamid_2` (`teamid`),
  KEY `probid` (`probid`),
  KEY `langid` (`langid`),
  KEY `judgehost_2` (`judgehost`),
  KEY `origsubmitid` (`origsubmitid`),
  KEY `rejudgingid` (`rejudgingid`),
  CONSTRAINT `submission_ibfk_1` FOREIGN KEY (`cid`) REFERENCES `contest` (`cid`) ON DELETE CASCADE,
  CONSTRAINT `submission_ibfk_2` FOREIGN KEY (`teamid`) REFERENCES `team` (`teamid`) ON DELETE CASCADE,
  CONSTRAINT `submission_ibfk_3` FOREIGN KEY (`probid`) REFERENCES `problem` (`probid`) ON DELETE CASCADE,
  CONSTRAINT `submission_ibfk_4` FOREIGN KEY (`langid`) REFERENCES `language` (`langid`) ON DELETE CASCADE,
  CONSTRAINT `submission_ibfk_5` FOREIGN KEY (`judgehost`) REFERENCES `judgehost` (`hostname`) ON DELETE SET NULL,
  CONSTRAINT `submission_ibfk_6` FOREIGN KEY (`origsubmitid`) REFERENCES `submission` (`submitid`) ON DELETE SET NULL,
  CONSTRAINT `submission_ibfk_7` FOREIGN KEY (`rejudgingid`) REFERENCES `rejudging` (`rejudgingid`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='All incoming submissions';

--
-- Table structure for table `submission_file`
--

CREATE TABLE `submission_file` (
  `submitfileid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `submitid` int(4) unsigned NOT NULL COMMENT 'Submission this file belongs to',
  `sourcecode` longblob NOT NULL COMMENT 'Full source code',
  `filename` varchar(255) NOT NULL COMMENT 'Filename as submitted',
  `rank` int(4) unsigned NOT NULL COMMENT 'Order of the submission files, zero-indexed',
  PRIMARY KEY (`submitfileid`),
  UNIQUE KEY `filename` (`submitid`,`filename`),
  UNIQUE KEY `rank` (`submitid`,`rank`),
  KEY `submitid` (`submitid`),
  CONSTRAINT `submission_file_ibfk_1` FOREIGN KEY (`submitid`) REFERENCES `submission` (`submitid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Files associated to a submission';

--
-- Table structure for table `team`
--

CREATE TABLE `team` (
  `teamid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `externalid` varchar(255) DEFAULT NULL COMMENT 'Team ID in an external system',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT 'Team name',
  `categoryid` int(4) unsigned NOT NULL DEFAULT '0' COMMENT 'Team category ID',
  `affilid` int(4) unsigned DEFAULT NULL COMMENT 'Team affiliation ID',
  `enabled` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Whether the team is visible and operational',
  `members` longtext COMMENT 'Team member names (freeform)',
  `room` varchar(15) DEFAULT NULL COMMENT 'Physical location of team',
  `comments` longtext COMMENT 'Comments about this team',
  `judging_last_started` decimal(32,9) unsigned DEFAULT NULL COMMENT 'Start time of last judging for priorization',
  `teampage_first_visited` decimal(32,9) unsigned DEFAULT NULL COMMENT 'Time of first teampage view',
  `hostname` varchar(255) DEFAULT NULL COMMENT 'Teampage first visited from this address',
  `penalty` int(4) NOT NULL DEFAULT '0' COMMENT 'Additional penalty time in minutes',
  PRIMARY KEY  (`teamid`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `externalid` (`externalid`),
  KEY `affilid` (`affilid`),
  KEY `categoryid` (`categoryid`),
  CONSTRAINT `team_ibfk_1` FOREIGN KEY (`categoryid`) REFERENCES `team_category` (`categoryid`) ON DELETE CASCADE,
  CONSTRAINT `team_ibfk_2` FOREIGN KEY (`affilid`) REFERENCES `team_affiliation` (`affilid`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='All teams participating in the contest';

--
-- Table structure for table `team_affiliation`
--

CREATE TABLE `team_affiliation` (
  `affilid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `shortname` varchar(30) NOT NULL COMMENT 'Short descriptive name',
  `name` varchar(255) NOT NULL COMMENT 'Descriptive name',
  `country` char(3) DEFAULT NULL COMMENT 'ISO 3166-1 alpha-3 country code',
  `comments` longtext COMMENT 'Comments',
  PRIMARY KEY  (`affilid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Affilitations for teams (e.g.: university, company)';

--
-- Table structure for table `team_category`
--

CREATE TABLE `team_category` (
  `categoryid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `name` varchar(255) NOT NULL COMMENT 'Descriptive name',
  `sortorder` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Where to sort this category on the scoreboard',
  `color` varchar(25) DEFAULT NULL COMMENT 'Background colour on the scoreboard',
  `visible` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Are teams in this category visible?',
  PRIMARY KEY  (`categoryid`),
  KEY `sortorder` (`sortorder`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Categories for teams (e.g.: participants, observers, ...)';

--
-- Table structure for table `team_unread`
--

CREATE TABLE `team_unread` (
  `teamid` int(4) unsigned NOT NULL COMMENT 'Team ID',
  `mesgid` int(4) unsigned NOT NULL COMMENT 'Clarification ID',
  PRIMARY KEY (`teamid`,`mesgid`),
  KEY `mesgid` (`mesgid`),
  CONSTRAINT `team_unread_ibfk_1` FOREIGN KEY (`teamid`) REFERENCES `team` (`teamid`) ON DELETE CASCADE,
  CONSTRAINT `team_unread_ibfk_2` FOREIGN KEY (`mesgid`) REFERENCES `clarification` (`clarid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='List of items a team has not viewed yet';

--
-- Table structure for table `testcase`
--

CREATE TABLE `testcase` (
  `testcaseid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `md5sum_input` char(32) DEFAULT NULL COMMENT 'Checksum of input data',
  `md5sum_output` char(32) DEFAULT NULL COMMENT 'Checksum of output data',
  `input` longblob COMMENT 'Input data',
  `output` longblob COMMENT 'Output data',
  `probid` int(4) unsigned NOT NULL COMMENT 'Corresponding problem ID',
  `rank` int(4) NOT NULL COMMENT 'Determines order of the testcases in judging',
  `description` varchar(255) DEFAULT NULL COMMENT 'Description of this testcase',
  `image` longblob COMMENT 'A graphical representation of this testcase',
  `image_thumb` longblob COMMENT 'Aumatically created thumbnail of the image',
  `image_type` varchar(4) DEFAULT NULL COMMENT 'File type of the image and thumbnail',
  `sample` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'Sample testcases that can be shared with teams',
  PRIMARY KEY  (`testcaseid`),
  UNIQUE KEY `rank` (`probid`,`rank`),
  KEY `probid` (`probid`),
  CONSTRAINT `testcase_ibfk_1` FOREIGN KEY (`probid`) REFERENCES `problem` (`probid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Stores testcases per problem';

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `userid` int(4) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `username` varchar(255) NOT NULL COMMENT 'User login name',
  `name` varchar(255) NOT NULL COMMENT 'Name',
  `email` varchar(255) DEFAULT NULL COMMENT 'Email address',
  `last_login` decimal(32,9) unsigned DEFAULT NULL COMMENT 'Time of last successful login',
  `last_ip_address` varchar(255) DEFAULT NULL COMMENT 'Last IP address of successful login',
  `password` varchar(32) DEFAULT NULL COMMENT 'Password hash',
  `ip_address` varchar(255) DEFAULT NULL COMMENT 'IP Address used to autologin',
  `enabled` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT 'Whether the user is able to log in',
  `teamid` int(4) unsigned DEFAULT NULL COMMENT 'Team associated with',
  PRIMARY KEY (`userid`),
  UNIQUE KEY `username` (`username`),
  KEY `teamid` (`teamid`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`teamid`) REFERENCES `team` (`teamid`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Users that have access to DOMjudge';


--
-- Table structure for table `userrole`
--
CREATE TABLE `userrole` (
  `userid` int(4) unsigned NOT NULL COMMENT 'User ID',
  `roleid` int(4) unsigned NOT NULL COMMENT 'Role ID',
  PRIMARY KEY (`userid`, `roleid`),
  KEY `userid` (`userid`),
  KEY `roleid` (`roleid`),
  CONSTRAINT `userrole_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `user` (`userid`) ON DELETE CASCADE,
  CONSTRAINT `userrole_ibfk_2` FOREIGN KEY (`roleid`) REFERENCES `role` (`roleid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Many-to-Many mapping of users and roles';

/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

-- vim:tw=0:
-- These are default entries for the DOMjudge database, required for
-- correct functioning.
--
-- You can pipe this file into the 'mysql' command to insert this
-- data, but preferably use 'dj-setup-database'. Database should be set
-- externally (e.g. to 'domjudge').


--
-- Dumping data for table `configuration`
--

INSERT INTO `configuration` (`name`, `value`, `type`, `description`) VALUES
('script_timelimit', '30', 'int', 'Maximum seconds available for compile/compare scripts. This is a safeguard against malicious code and buggy scripts, so a reasonable but large amount should do.'),
('script_memory_limit', '2097152', 'int', 'Maximum memory usage (in kB) by compile/compare scripts. This is a safeguard against malicious code and buggy script, so a reasonable but large amount should do.'),
('script_filesize_limit', '65536', 'int', 'Maximum filesize (in kB) compile/compare scripts may write. Submission will fail with compiler-error when trying to write more, so this should be greater than any *intermediate* result written by compilers.'),
('memory_limit', '524288', 'int', 'Maximum memory usage (in kB) by submissions. This includes the shell which starts the compiled solution and also any interpreter like the Java VM, which takes away approx. 300MB! Can be overridden per problem.'),
('output_limit', '4096', 'int', 'Maximum output (in kB) submissions may generate. Any excessive output is truncated, so this should be greater than the maximum testdata output.'),
('process_limit', '64', 'int', 'Maximum number of processes that the submission is allowed to start (including shell and possibly interpreters).'),
('sourcesize_limit', '256', 'int', 'Maximum source code size (in kB) of a submission. This setting should be kept in sync with that in "etc/submit-config.h.in".'),
('sourcefiles_limit', '100', 'int', 'Maximum number of source files in one submission. Set to one to disable multiple file submissions.'),
('timelimit_overshoot', '"1s|10%"', 'string', 'Time that submissions are kept running beyond timelimt before being killed. Specify as "Xs" for X seconds, "Y%" as percentage, or a combination of both separated by one of "+|&" for the sum, maximum, or minimum of both.'),
('verification_required', '0', 'bool', 'Is verification of judgings by jury required before publication?'),
('show_affiliations', '1', 'bool', 'Show country flags and affiliations names on the scoreboard?'),
('show_pending', '0', 'bool', 'Show pending submissions on the scoreboard?'),
('show_compile', '2', 'int', 'Show compile output in team webinterface? Choices: 0 = never, 1 = only on compilation error(s), 2 = always.'),
('show_sample_output', '0', 'bool', 'Should teams be able to view a diff of their and the reference output to sample testcases?'),
('show_balloons_postfreeze', '0', 'bool', 'Give out balloon notifications after the scoreboard has been frozen?'),
('penalty_time', '20', 'int', 'Penalty time in minutes per wrong submission (if finally solved).'),
('compile_penalty', '1', 'bool', 'Should submissions with compiler-error incur penalty time (and show on the scoreboard)?'),
('results_prio', '{"memory-limit":99,"output-limit":99,"run-error":99,"timelimit":99,"wrong-answer":30,"no-output":10,"correct":1}', 'array_keyval', 'Priorities of results for determining final result with multiple testcases. Higher priority is used first as final result. With equal priority, the first occurring result determines the final result.'),
('results_remap', '{}', 'array_keyval', 'Remap testcase result, e.g. to disable a specific result type such as ''no-output''.'),
('lazy_eval_results', '1', 'bool', 'Lazy evaluation of results? If enabled, stops judging as soon as a highest priority result is found, otherwise always all testcases will be judged.'),
('enable_printing', '0', 'bool', 'Enable teams and jury to send source code to a printer via the DOMjudge web interface.'),
('time_format', '"%H:%M"', 'string', 'The format used to print times. For formatting options see the PHP \'strftime\' function.'),
('default_compare', '"compare"', 'string', 'The script used to compare outputs if no special compare script specified.'),
('default_run', '"run"', 'string', 'The script used to run submissions if no special run script specified.'),
('allow_registration', '0', 'bool', 'Allow users to register themselves with the system?'),
('judgehost_warning', '30', 'int', 'Time in seconds after a judgehost last checked in before showing its status as "warning".'),
('judgehost_critical', '120', 'int', 'Time in seconds after a judgehost last checked in before showing its status as "critical".'),
('thumbnail_size', '128', 'int', 'Maximum width/height of a thumbnail for uploaded testcase images.');

--
-- Dumping data for table `executable`
--

INSERT INTO `executable` (`execid`, `description`, `type`) VALUES
('adb', 'adb', 'compile'),
('awk', 'awk', 'compile'),
('bash', 'bash', 'compile'),
('c', 'c', 'compile'),
('compare', 'default compare script', 'compare'),
('cpp', 'cpp', 'compile'),
('csharp', 'csharp', 'compile'),
('f95', 'f95', 'compile'),
('float', 'default compare script for floats with prec 1E-7', 'compare'),
('hs', 'hs', 'compile'),
('java_gcj', 'java_gcj', 'compile'),
('java_javac', 'java_javac', 'compile'),
('java_javac_detect', 'java_javac_detect', 'compile'),
('js', 'js', 'compile'),
('lua', 'lua', 'compile'),
('pas', 'pas', 'compile'),
('pl', 'pl', 'compile'),
('plg', 'plg', 'compile'),
('py2', 'py2', 'compile'),
('py3', 'py3', 'compile'),
('rb', 'rb', 'compile'),
('run', 'default run script', 'run'),
('scala', 'scala', 'compile'),
('sh', 'sh', 'compile');

--
-- Dumping data for table `language`
--

INSERT INTO `language` (`langid`, `name`, `extensions`, `allow_submit`, `allow_judge`, `time_factor`, `compile_script`) VALUES
('adb', 'Ada', '["adb","ads"]', 0, 1, 1, 'adb'),
('awk', 'AWK', '["awk"]', 0, 1, 1, 'awk'),
('bash', 'Bash shell', '["bash"]', 0, 1, 1, 'bash'),
('c', 'C', '["c"]', 1, 1, 1, 'c'),
('cpp', 'C++', '["cpp","cc","c++"]', 1, 1, 1, 'cpp'),
('csharp', 'C#', '["csharp","cs"]', 0, 1, 1, 'csharp'),
('f95', 'Fortran', '["f95","f90"]', 0, 1, 1, 'f95'),
('hs', 'Haskell', '["hs","lhs"]', 0, 1, 1, 'hs'),
('java', 'Java', '["java"]', 1, 1, 1, 'java_javac_detect'),
('js', 'JavaScript', '["js"]', 0, 1, 1, 'js'),
('lua', 'Lua', '["lua"]', 0, 1, 1, 'lua'),
('pas', 'Pascal', '["pas","p"]', 0, 1, 1, 'pas'),
('pl', 'Perl', '["pl"]', 0, 1, 1, 'pl'),
('plg', 'Prolog', '["plg"]', 0, 1, 1, 'plg'),
('py2', 'Python 2', '["py2","py"]', 0, 1, 1, 'py2'),
('py3', 'Python 3', '["py3"]', 0, 1, 1, 'py3'),
('rb', 'Ruby', '["rb"]', 0, 1, 1, 'rb'),
('scala', 'Scala', '["scala"]', 0, 1, 1, 'scala'),
('sh', 'POSIX shell', '["sh"]', 0, 1, 1, 'sh');


--
-- Dumping data for table `role`
--

INSERT INTO `role` (`roleid`, `role`, `description`) VALUES
(1, 'admin',             'Administrative User'),
(2, 'jury',              'Jury User'),
(3, 'team',              'Team Member'),
(4, 'balloon',           'Balloon runner'),
(5, 'print',             'print'),
(6, 'judgehost',         '(Internal/System) Judgehost'),
(7, 'event_reader',      '(Internal/System) event_reader'),
(8, 'full_event_reader', '(Internal/System) full_event_reader');

--
-- Dumping data for table `team_category`
--
-- System category
INSERT INTO `team_category` (`categoryid`, `name`, `sortorder`, `color`, `visible`) VALUES
(1, 'System', 9, '#ff2bea', 0),
(2, 'Self-Registered', 8, '#33cc44', 1);

--
-- Dumping data for table `team`
--

INSERT INTO `team` (`teamid`, `name`, `categoryid`, `affilid`, `hostname`, `room`, `comments`, `teampage_first_visited`) VALUES
(1, 'DOMjudge', 1, NULL, NULL, NULL, NULL, NULL);

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`userid`, `username`, `name`, `password`) VALUES
(1, 'admin', 'Administrator', MD5('admin#admin')),
(2, 'judgehost', 'User for judgedaemons', NULL);

--
-- Dumping data for table `userrole`
--

INSERT INTO `userrole` (`userid`, `roleid`) VALUES
(1, 1),
(2, 6);
-- Generated by make on Tue Aug 11 22:22:20 BRT 2015

UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B474801742CE80000008401000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300008550C16AC3300CBDFB2B3437D0535276ED286B5873082C1B2CDB07288ED2883A76B005EDFE7E4969A0F4325DA427E93D9EB47ADA34EC36B1576A05F92107E387912DC139E0385248A3093C0A743EC0FA36CB62BFCEA6F59A08A44781BB9DF8EB042F80AE85C10702769DCF943A14F5F74E27CF1A5E20F6DC89AA8AEABDACCAC76E5E7ED49F3F5F6FC5B53F9B4AA3A0B0D9C212F51583657782334B0F68ED849A808129CE8C06C331DE11FF611C1DCA80275A18907AD0C96C594F79AF1F04155D588C6F6997BCCE068D25746002A1500BDDF4A0B8556180B4BBA9645E2F155A9E8E9A05205964D41F504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B474801742CE800000084010000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81250100006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000830100000000, md5sum = 'd9c04447e1b745b6ec6e22e1e0bf2e08' WHERE execid = 'adb';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47D9F45717C90200001605000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D54DB6EDB300C7DAEBF8271BAA5DD9AA4D963D6162812AFCBD0C44093600FBB148A4CC7421DC990E45C30ECDF47C9769B167BB12D8A3C24CF21DD6EF55742F64D16046DB8DD3D01579B42E4083BCD8A0275D7702D0A0BA9D2D0A9EF7A26EBF4C87D8E083663168E7CCC415AB6072613D8288D2064AAC897BC1799308D67A2D080541618B725CBF30384357648880846959AE305AC4A4B85084BDE8C204C8679DE60F8CC3B4186B494DC0A2581191F8D7BE4A565AB1C87B0CB5002A714985C80B004E2432A173C4A46769BF933575A23B754BA455D68A467DDD605DD978630084FED845CD3999A7A714C1A30AB6085501AB258CDA429183D2DF549258AB42E84BEEBAE1317C0C058E28DE54A2290284C1F2AE666F162328A8655B23A42373470261D914DB6E72E96F3E871F4F5218E1784C0954CC5BAD4CCD3A40AFFB2A59614A1640BCE96324763A0D08A34A717BE894809C473936945D9506E85567283D242466DAC9058B6ECC9734DAAABB4771E04E368BEB80E4F07217C26E9446A836934BD9F4C276FADB793D93C5E3E8C226F779338CA903F5543D76E755E49910B49BA264A766CA503B1E9E8A3EBADABC722DB388D52AD365030639C4E55CBC6F9B9368EF07A01E9B1D65840E7B74B159EBE9413C24D3FC16D5F9634329F6EDE0FA8640A97C109F24C411869ADF4F0F5A05866D1F17266CEA9FE5226C33038F1F85DF9BF1484B5A70606412A02BF25E8B6C66D07144AFB29A64939F8CAD1D86A62AB255329ED19305ADA6A167A0EE0BB5B977ABE5DE7D5D530E0B42D3794DA8912C2D555147F09DACFCBDF863B94486ABB11765BD6EC3DA56D76C5253A6E95E6A29A769F774C365A9A4468C936E87F003C63728DCE74AC4FEAFE2E6E643D3B808E43E355F801E1CFD33F97EFFA1FFE86D0BA76A7CB107E359CF3E4E8DED3E52AF36575B710CFEE27B3E8F1DB727C175D0F9C651C4F9F4FE91BD25DF701CF362A01F671DFD0E210498BCBE01F504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B47D9F45717C902000016050000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81060300006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000640300000000, md5sum = '7ce6a74e5f4347a6b3ae4d3cb4d0e59e' WHERE execid = 'awk';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47B14509615C0300005006000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D545D6FDB36147DAE7EC58DECC5ED96D8491FBD3AC36AABA987C62A62071BB075054D5D5944655220A9C446D1FFDE7B292976D2BE48FCB89FE71CDEDEC968ADF4C81551D483B7C215E00A2C4B90665BA912E1C18AAA427BEEA4559587DC5818B47743570C86E4B544045F080F47366EAFBDD881D0196C8D45503A37644BD6AB42B9CE3233E8401B0F42FA5A94E51EE236764C11119CA9ADC43358D79E0A519EAC0585682A6C6384CC0F8A0EF25A4BAF8C06E18237EE50D65EAC4B1CC343811A24A5C0EC0C94A720C1A531C1A36474EE8BB097C65A949E4AF7682B8BF46DDB3AA3FBDA510C8A671E94DED09E9A3A18665D306F608D503B3AF156685709FA7AEA934A54795B08ADDBAE337610E03CE1264AA311881B61F70D728B74359F26E32659EB613B18A4D00C6497EDB18BBB65F279FAFE364D5714411A9DAB4D6D4580C954E1E76BABC98356B52ED139A8AC21C6E987CFEC730A119029ACA15CA8EF95357A8BDA43414DAC9130F6E24B409A383739ABE3ED1E32CC455DFAE0BB66891D98016AA5345230664A43D0229B9C11634A16E4CF1AD1030F1B642A64596764BADE3794158AC499B5059D136ED63B6FAA21CB38E0320C8AAB1D69089DCA905922B3B264D6422D94F5E73DB14E2883A9CB8C82BC6455E34E6CAB125F31CCD254AA216C543BFB58F8308A66C9723589FB9731FCCE15E63EBA496E3ECC6FE6CF4FFF9C2F96E9DDED3409E751747BB7483FAEE6E9623989637E8FD302E597E6CDF54E064F94480D90AC33C3D0041972B5540C5DDF33211EC596259A5BB3854A38C70D378C3BB6E39E8FE20D2392E3C6620583FF3955DC3F5417C3D528C3FB91AEE9C5BCBE3ABDA40EC85D472F501606E2C45A63C74FDF89274619C497EE15D55FEB6C1C472F42FC73FDB314146B470D5C46B93A34DEBCB6711478EA1FD0E1184FBD937FE6AB693A4B26FD3FA27FE9AEDBC7648A70019FE0F4144286C72B4EF337CF94568D8C4FA39971447A842B0AC34CC6F0E64D92BE8B7A8F83B207D7A8D106CD8651D40D4782B51B28CD883A86841E503314869C794667345B3265B5D8629893B2107A837C74CC63CE43985F76401190B176812DEAF3BFFED78B5F46BF7E8BE164C2BB8B183E75DCC8ECE83EC08ABBCA580FE9E2C37C917CFEEB6E769D4C2E6196DEB44BB640093FA0FD0C6AC22292C5D664207EDB7520B12FA17B117D07504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B47B14509615C03000050060000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81990300006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000F70300000000, md5sum = 'fa8bedd9947c16fdd315293771f2e491' WHERE execid = 'bash';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B478B499076750100003D02000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300005D515D6FDB300C7CB67F05EB06688A2229D64717C35634C690211F40D3A08F83ACD036515912247A71F6EB27295931540F12C5A38E77D4F5D57D4DFADE77797E0DCF204D6F49211C9DB016DDCC4B4796A1310E6E2ED8DC7737F350BC4304EE04C37F35FEA4598C20F4017AE3104837669EE78B6AF7FAB5987C29E0117C470DE7EB6ABD5AAE979FB34FCBCD6EBB7F79AE523E4A9A8D204B88AB1AAD2249AC4EE0913F942AA1DB41B4418B09FAA73AEC77772006360764940CF5097064D49E8CBE8D8C6F42A9327B416B1C4388E1289C26DDFA086E1FCA2C5BE16F54F000C632F5F4477078EA617AC0460CEAE2D4221E129DE780CB32DBA51314E977381277895A51ED84234CDC962C96D9DE23C4C8279E60A31F34C9D4036AE423A286C0D98602D35C6C263452A83ECAFB68D10BEE66E71E279876C2C729D471283E5873EDD0A3E6ABDBBC95324DF26C3EBAFCA7FBAC0A668BED66B5DC54BF7EEE173FAA705D6CD797D04031891F5884F37B1125E43812C3E45BFE17504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B478B499076750100003D020000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81B20100006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000100200000000, md5sum = '33adacb57564f8b7d552959b33e0f5e0' WHERE execid = 'c';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47213B2169B6070000971600000A001C00636F6D706172652E63635554090003A79FCA55C39FCA5575780B000104E803000004E8030000CD58DF6FDB38127EB6FF8AB10F49E544B593EC3E254D80A2971E72E8E51EDADE1E5007062351313732E51369BBC16EFEF7FB86A46449719202BB385C1F526A86339CF9E607879E4C28959958E576B616B94A852D4ACACA6241F7C25A65685916B7B95CD8A2C8F121927B7127FB9309E52A91DAC894563A9525FDE3EA4B450297372C8A54654AA6A794E585B094148BA528952974FF2F4A27F92A95F42E33B6946271D120A9E2290D14A5EF9A94C4D854155D4AAE6E3BA42772C21859DA166921ECBCAB499410EB2785369694B674F9EFAB2FB3F71FE89C7E3E39EBD27F79CFF49FCEFA7D489E9EAAE015FDBA4AEFA4D2B15F086DCEFA1FAF3E5DD281FB5E4863002644AFBF7EFA54B1005AB62C4C4DE5432AF1191831B1E79A971D66AEB4ACB8BC86399303FA32973E00008296054BD887A5A48DA49591EC832CB5C8F387533A98F499857CA0BCC0EEB45821F490B650B52E544A9B12F4190EDBC832F220247351D2812CCB98C6E3F1887EEBF7D602E783B55C8BF2CC7D1A2B4A1BF1774CD83A02355B2234368B9A50C434FC854F207F02159AD811DA4BA9C8A858D9E5CA12CE2D4B6996854ED9255BD47B94AE043395CBD1540FE37EAFD7DB2212B7C16233D6BBED70FEB0BD2F980AFDCC5519452168CEFB7A7B2062276CDB4B87F17371642D8FFD9EFCAE6C14F209A4C780B9139AC1A0E28F428EA2BCCAA8957B7361F41B4BB7526A32D2D26A490FD2C608B4B292DCA18C304CC5DAFB3A682A18512795FDCE3F05585FA9D160F87766D3251B33F4C0DCA21B91322EAF5BA00056A42BEDA397395C1CD596C2CCBF9D1CDDF091E0AE43D48C4984CE2217A14FD9DEF191418CF6D7B11718D1E09C8E47544ABB2A35652237D2419BC34D561118B65C496794958B652E00DB3BAE222D16923E874EE6025980C88919792AEDFB2E1153D301DED0A66CE6855828E78D1718B3A2C8A578E588A76742E5D1C82761336B867B064D184C746B0493C569CF707990571E53A5ED911DF18DC8992B657A8B9EDFC2B822A6AAECD81E182FD88FEEE87B32AE123BF7F95291A286E2111DD27032C4DF5D1BD8526F241A0194640E11D6384E90F8653442483775750EB0EB475181AED2653FCE6BE0D3D41DCA35841FBA5DF4B9D54A386D3705E9D5E256965E97FCCF0AF7AA7D88492449B1D2AE0F33E370F2F6EAFA634CD7E21A6D2BC5452B1365147A1EFA30B769271971C266C73EADB393F03FE7FD4CDC9A992DF226A994399346FDDF7CA6630B77A11856E6BCE02670401F95E6EA4626AF009F2865B89B01C446212AA640EA428D2C854E249BE360F4A140D539F128436DECEF77892723F25087A3393A58C28FE3B760C2805EB0A5E604D6A4663B5C0751A5E1A2ED2F1F5AA9B8E8F8ED23031719540C2F0E428E2E7F77FDD042779C7014E74130E2D80376A5B3279079D5D067E7529564D49D260C12C91CFCEE490A5DA67D92A3D45885D37CAA43D12D2E02DE7F7EDEA19D6C3DFC973705771E23214B898C4972EE99DE3E916FC483D932C7CEAA70D2914BD966957EFDFCFE6F9708C9F02B37E153AE045F2C38C02F706F5155803394287D2B9616E96A6EE81D59F49F192EE8212605CEDD85503AE205E6A8240E671CE063ED3C5659C40C08FEFCB4309D29314BAEBF1DDD048F3BD74CAB39B99D3FDDA0E69BBBC6F6BB1DB6D46C47AB67C4C306C56E3D15AFFB773DD639E6F1CD0BBB005AE09EB4B6F57BEE0AC3342A670643338E5C4B5711FE96715C83715BCE809DBE7B6117A6B899AB02D3E03CE912E0BD3D6E3142CD040638E8493E643CCC9EE1BF772E7A677478287C9490D3E15F34402B4C164B0F9E60F0DABE0CC33DD47BE2A2BF2F7BBD4792390FA0D92E65BB5DAF953E8BCC0F29AF8129F29595B3BAD3D5EA594C1C1E73FDB934FDFD771A54D3865773C8516F013C1AB1E42B89DCEB01CB1FB40FF111ECD51FB5AFEA8D7FB67DFF53B3BAB9DCD2B1C37067CF2B4A1F5D6369974FEB988B733A6227DAF5C254AE97E630EF0799EA55D66BBD326A5EF840B1A180DAC39013885D1785F8668EFE4111E7B2471683FB67CEF801D107C1F37ACED9EEEE6A85613D69D3D08641C6CB0092419532AE62EA9E345E4A798F49A6AA516ECF096C8B7835AA77DD491B79FCDD94B9B3E8828A1E778EB41AE812A51BC24E3AE1713AAD76F75A2FC9A1F38EBC6AFFEA38A5BBC2F2A34E7E5FCAC4CAF0824AE16D50FA58AB4E39E3DE4CF51B4C8D87CDF76FCFE545333241CC1BD4906A452CE45333C0215FBA78D6CEEEC033ADF1DC01C9EB78BE0E90B38F5FC5FC3876CAE20A34F7030E671343366AFBFD125A1DB030237899419D397471E10FF6857B8B87C7FDD9765BE52A6FE3F32B44DADE7CC5C38E2EFFF9913C9CDE91B94869519432BCF3A73ABA96DFC3CF1B18E1EEA5E6A964543DA39BD3380C75B7123FBE71BFFD8A310DC584BF67C1B046916306AB7A524B4FECC49AADACEE5DECC8769B6D6CEBF87559E5AA9373D1609B87BEB25B166FE331F073FED6E8F8E97CDF6A983B8FFE521494A3BBC97AE24BE478AAC9BD9D4FDD730FEF13B108CBBFD69B40C825283C6EF3D0CF9F3C5F576B06DC976CAF471DC4DAC0F8699EFD78EB307AC58F1A85C65DD31E161AB10877D00BE7BBE7FAD133D5E3BBAC4B22430B65DCA03ED5019C299E82D3E1547B7CFC5737CD9E0B61F3BEC154CB76C287FF535BAB41BBBAB50ECF83602EF59D9DFBDE547700663B450D2E77041F8F4E9D3B5F3A2959E271CDBEF8823E9DEA9DA5C02AB73F7DBDFFE07EE1F92F504B0304140000000800B6B20B47344099EB86000000A400000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E80300003D8BB10E8230104077BEE28C239C4477278584A90635C689D4B34063E9916B89D1AF9745B6F792F7D6ABFC617D1EFAA44B53C00E506D016FDA39C036444D2F1C85A3A1C802786C4A555FAAF2DE9CD5B53E14FBDD5C9DAA623E5A9641C70530189AC4C60FA0F6C1028EE6A97DB404CBE132FC66629CF05F3CBF018887518BD9100132C8E4931F504B01021E03140000000800B6B20B47213B2169B6070000971600000A0018000000000001000000A48100000000636F6D706172652E63635554050003A79FCA5575780B000104E803000004E8030000504B01021E03140000000800B6B20B47344099EB86000000A4000000050018000000000001000000ED81FA0700006275696C645554050003A79FCA5575780B000104E803000004E8030000504B050600000000020002009B000000BF0800000000, md5sum = '1084789966ed1d5c426e5234cae40dae' WHERE execid = 'compare';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47FF4212BB21010000AA01000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300005D50D14AC340107CCE7DC59A16AA94B6D8C788A83441224D038DC547B9A69B6631B93BEEAEA6FAF55EAE11C4A79DDB999B1D6674B5D89358989AB111ACA6532865ABA841E834570AF5CC949A94854A6A980CDCDCD493B9931788606B6EE18FC67C09CBCFC0C5015AA911485472CE589C14AFF7E1F836843B303555966549B64EB3F4FFF629DD14F96EBB4AFCBE0F357BE34D13055B54525B70183AAE0589A3E9C97C1905C11A3FB181254865A9A56F6E490A03D707ACF8A9197229C4C34DFFC358C7975150F8090D890FE8C8D6DEBAA1BDE69AD07B2B5218053B83D023E37D5C05ED4950E96FC01E6D8728C0791E9D4056437D9E654757A74FDFC7FC3D7CB185599C6FD6E926797FD9C5CF897BC679364009E1B8EF2B74F3316478260BE307F603504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B47FF4212BB21010000AA010000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED815E0100006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000BC0100000000, md5sum = 'c3a36a132c87fa335d25416abf06f684' WHERE execid = 'cpp';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47C5E1A1B66D0200007E04000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300005D535D6FDA30147D9E7FC525B022AD0DA5AFB4EC0B3296A910A98036A9ABAAD4B92156C18E1CA7A5AAFADF776DF2C1FA12C7F63DE71E1F1F773BE70F429E1719635D987481AB5D2EB608CF3ACE73D47EC1B5C80DA44A43BFDA1B14597F40D54B4430596CE0A8A6789126DE432C13D8298D2064AAA896AA579928EACA8717837EC556C0B330191121CC166B4249558BD08E678312756CB02092188A0CB7DB9AC728D0A504615A0E879F5C87C491608D25615B62D007258B68154E82119593A2A65545C96329152944280B4C5ADEF532B89FFCBC89A215B326C9546C4A62164A82CADD604A2D09A1E4199492CE5540AE15594803BE03A4C4614979A6153543F924B4923B9406B2B8A0E64874F1237D794C26AAB4C3D83458AEC65EEFC2834B3241A486CD83F975380FDFAF7E0B17CB687D3309DCFA014886D0ECD5FEBE0D708FB47CA899863776A3057D3CFFF4E6B15BF07A4D8107639AB6251EDCC1C909B404FD41DFA6E7FBD1AD8ED866C70BF0D529F8C9285A5C878BE0FED77A3A0BCEA6D1DCFDD06669465EAFD2E7518FAF1E0BFE84AB49340DC6BD2F4E453DF7C09708C3436BDCD395375B2EB919F247974022CD4B0AA3132152B8850EF8291CF5B9BBB4E64BF60179A6C00BB4567AF45F261307877E8DE983CD44AA4A990C3CC2D9F6172C15B6F36F2D0C9222E4A5117253E5E8AC5AA178BB44D2ADD7394E9A788E18A7D7F3B9D2E6C1D55510FD60DDE6457661D6605CEEFD36F7157DC35E730EACA6291AE40612A165BC43F78A7816CB0DDA258BA6483ED9B4F16D4C396D0E0768BD280607DFBCBFBDD7A1CB0374C676363CF28E2747FBCE0AABE820A7F59AD903319EED5402F1E9BE3EA92D260B87EC1F504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B47C5E1A1B66D0200007E040000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81AA0200006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000080300000000, md5sum = 'b485f98febfbdd4bff9eef72142ccf84' WHERE execid = 'csharp';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47EB22191737010000E201000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300005D915D4F83301486EFFB2B8E8C647A01532E671635030D668C64B878693A388CC6D2366DE7A6BFDE82F523F6A63D1F4FCF9BF74CCE663B2666A6236402F7525B4D05D4B2578C231C35550A75646ACD9485566A98FA5A6CBA69EC900A116C472DFCE931EFC2D21350D1402F350213AD8C0949B3EA69118457015C83E9586B499115ABBCC8FF67EFF275556E37CB6CCC0FC2A267CAF91CFCD9A07242C1A5E048B560626F869ECBE4A70360856FC82101A92CEBD907B54C0A03E70DB6F4C0BD4C85D85C0CA4B1AE5E7BBA1A03E04CBCC291D96E9CC3D94E53CD701C542BF53B697310B004A5516959A33152937DEB7DF41F7FC987A84C4616A2B45CAFF275F6F2B84D1F3217A665E19F128270F02970F76D40F0C46C2D1B5C8437830D35C7613B1AA9C5065AB7063327BA87A8F5582C9D5D0304E1374A3E01504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B47EB22191737010000E2010000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81740100006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000D20100000000, md5sum = '0b24c3e8918ac93d3e34f79671453734' WHERE execid = 'f95';
UPDATE executable SET zipfile = 0x504B0304140000000800CAB20B479E3BA9076E0100001203000008001C00636F6E6669672E685554090003CC9FCA55CC9FCA5575780B000104E803000004E80300008DD25D4FC2301406E0FBFD8A377AA1121CC384041363826C9119DC0815C4ABA56C67ACB17464ED88FC7B0B420257EEF67C3CA7ED69A70566EA25D252E562E516C885249812156D244F0964D2CE29D98616CAC64CC10D8446A9E4CE410B2B5254714319786EA842552B25D4EA88D615B5A14A03DB74B3E6DF844C68730323D6E4EEDB3FC9BAEB8DDC816B5DAF090555C72119E5BC96C64678469506B709BEE542F2A53C34771CE7DA160945F0E3F7B799FF1A24F360CAC238C255CFF55CEFCA713A2DF87F35F6625D881CBBB246C1B7FB2984276D32A18C5B3C1FE71C1EC1DDE3277B34980709FBF0C3E82319A1DB889462D9841C872F0DC99D96E5EA7FF28B8DE3D76664ADEC26B27FC95914DA83362207110B313CE7F485679D61320A06BEDDD1910B552AEB8C308959B870BBF70F9ED7C7926BFB2B36948A5CA4DC88529D2BC9A13619262C9E4D8701F62DDEE3F8826333B67DC0AD3DFB028FFD3BD08F21A52DA42FA4453C09A293D3F33CE717504B0304140000000800B6B20B47ADC6252E89080000501800000B001C006C69622E6572726F722E635554090003A79FCA55C39FCA5575780B000104E803000004E8030000B5587B4FE3C616FF3BF91467BD82D86002ACDAAB5B685AA50BCBA5E225D8BDB72B8A22C71E27BEEB8CB3E37168DADDEFDE73E6653B413CAAD6420A9E99F3FE9DC77877AB0B5B702C4421601AF124CFF804F017F26232A1FFD38AC7322B7889E7E8E85524241429C82983A3CBF3FF57C984C1952826229ACD88E06DC1252B25FC5C8925DC2C4BC9669A6116331EB38498543C6142B138B9F8002757677DB8610CAE8F8747E7C7EAF4DBCBAB8FA7172790A25E09935196977DA4DCED7677B7E07436CFD98C7119916676FFC06838CC7388C4A4A2033B7986AA8CA39225B52510477804A5670216D1481DF117FD7E007151A1F2628E3692BD200B88164596405254E31C79C445C2FAF0AE12482D6685602110AF9A755532E82DD079B372D223FAA42049C42C8A6515E5702F32497E323EA4A3AC2C23F422D94DDC184563F73E12BC1500E24D7C147B7546099830CE442499E2A696771A3C5351CCD44EC6E795EC83A3C505656125B8F247A9694B2948E82A5FA3BBA634BC0F753C5E673CCEAB848117173CCD26FDA9D75CCCB3715F91B5D7BF2F65425BD31F5A6B24BCBD56710C4FD25E93D98CD10A61E188A5196714C7B8982F6116C5A2802C055E488C1DE222C2C0813FBCB83985B7DF7D0705CF97014109CD98C5F3A51F4056428A1E1847F12728ABC904D18BA11E2FB5E5952CC830E4CCD105218C2B89416525EF49E2725F884F709FC9294CB6B7913B0CCF8FE05FDF8C3309F33C9288DF9992F6EEF497F3E303B866B81A33E2EE3853BAFCA89CF93A4B3133526B0DBDD3EB68E4169296B97E82A42194220EEA437A91D6BAAF598E987984C8F860532F6DE21A6E64BFB322F54D6604C48527596A7FC8E91F10E5739DF3C0A319A10BCA65696B06BA5F8B4C9A465D5D5F9E5C0FCF9D3AE61D2E3E9C9D39E6E810CCC68C4B60BF65729462002BC160003BFB874AF47F239151484B2D82C4D5702F61C1C4B82833B924082370107ABBB89F660802D485189B330CD43380B3CB93D1C5E5FBD3B7C7877A1FCFE76CC1F2C6FED1F14F1F4E5615A0DA2405A2C628A1EB651467396638EEA3BC77A767C7B045582F26561ED96B24699F8D8A39E3B4B3A7259C47E84E9BF608C24862DDC16297610DB062A8109100559D4CBDF18927FE2AE543D0AE8CA791802DF4CF2474C52E9A07DD3FBAA40D65D2080F5542D0BF876A5191D0ABCEC7DBFD37FFBE3BEC7634A77195A64CE02B09D32F39E3F8EE987F7667913E842D8CEC5C5A0A63317A096DEDA0B1EFA7987EE5B4A8F204382A4E6D684EFEB89F325D99A87453158BF8D216CDBA268E595EDCF7C9131D449D4FB5693218908B2180685C08E907569250A050CEB690401A4CD4AC5CC12BC115C34ED1337C75081D6713D1016200D9F9E66CE8451E4AB3585E15AA6D7F50A616F2AA0588CD4DF0D1838309938C2F7CEFE8E7D1CDC71B14E505C12BABC81FDD4EA7F6292A8414B2C88930DCD49E0FF7F750A98E1661A23118EC19E20EC94272DFA463A8F3E1E8F86CF811BEA897ABD3A3B01138C5ACD3D47400FBB4F6B58B7F187B03265CA61F9F34251A5429550B35B45CB1A9978210BC8D316C24B0F19F838DF3838D1B2FC470211014EDA6E51EA8B03A006ACBF19F26AB6DB344A58ACA945B209404DB6F30DF0C0724F73566831942AE887DC7995457AED32B0F81ABE4739427534314D67981C6DC6E9477B051DE6E247707F8FB2BF7C26E07ECD3F4855533C4DE2BE759E2A32F94A62443A3DB24F7F7035BC374106D658F3E8794DC148C456A74D245D0EA84FB9FD57E9AE6553935BB9A221A21387CBDFF754DA2AB8A884B0DFF16089F50018F3FA202EE3EA442B7930AC68C571FF2424BA70620B54A2EB40B155274B3AFEBA0D14F53F875C5F4364ACF6AA9356C89478DBEAA023D6C4D97F7820A96A82B7624708C7455D955E96716E93E0EA2589DEB7A3AD7C5B5943895FAD1BC81095BF76B760DFBBACE9BF4A6157FE79A4A63BE6B8F9B1A8C07D4087640F90DCF9434281458CAA8E59911D1E78C25D804D145AAFFE131116832CBBAB4A3A2ABDB380D29D6F4A05CB99C33E88377001EFE90F2F51B6EE354120B7D1CBB018E013D43D3C3C6C0B1F683F7BFE1F505DE133CD805EFF8FAFAF2DAC3E4EA11A71E95D8C88D2956A7C4E9E4A32DAA36110532E6D54CD1A8A93C2A55AFA2CB0BF5A09E1A8F79A1887E67A208BA18561DB6C6DCEC37C3498A867A9451CCD783ADE24C1570645B29BDB8F6698C0DD57FCA1761DD7F5577B961D2B991429A2DA8CDE8F8A88B531A55B9A4AD9E724EAFEE3544336826B0E5A30A6952CD7DA4B8797F5DB70E7360BD0076BE02CD992B5C6C3DA55793CDD60C370439C6E81E78850350AD8B3D88CA2807FBCAFF0D69AEDDC340B37B90960CF12AFE8917F75C23DDB3B5A5F678DD3C8CFA41A342E3B30D7ECDD508FB11953D6890A9DD609DB0A5213D2D42858235A26FEBD6B6DE984CC7A4C500EF15B5154F362AC3F276EF0EB9F67EDDEBA9DE250566B8EB5CD601876B3B94968D1A4C66BD728EA767E5FC4AE76A9EDFDC34163BAFD69C1E95BA7EFE01FD75241C8D86A3E3AF4A7AC3CA7518612F31881C68445A929AB160EADE6C73F191E24A777ABAF19B32DBBCEEFB5549796A8A78D09AE635E41FAB1DABD3FCCA78DEC04FB33EE99C0E1DD7B55642F31E1E6AF46ADD4BDA9DF0A56D50DBDE6884CFB1EF858DB0AE12D6B0471AE15931C1E6C0DB1F3454B0E8DAA9EFF3BCE03B54EAD552FBBEF517C2F3848A24C36F5E795FEAE5B68BFF6EFFFE05E7829D28AC779DF7CCC63F006F9A069EC6B79919FE4E8C5B5BAD8DCF33F12511B01C9F1983A19BDC223B1028502FCCD70BF785547DA6D04AD563F233A351AA6BBDFE5C309BDFBEB933977C75F159FD26D06D5E11F404AEEF6D0B777D4226E17EA804EA2B40F33E604A35DD6C1B4D114C574456DBFB41E09A5E6366C05BB976463DDE7AC183FAB4B5A12BB462FB84467C30D8D9872F5F80FF90ABBB8796BD177A38A4D267485DFFE9CB2E8EC14D054C1B516E7C11DC6CA0EAD83D12BA0751D608601B7206711DEDE6959B937653136DAB46FC09504B0304140000000800B6B20B474F26481915040000910C00000B001C006C69622E6572726F722E685554090003A79FCA55C39FCA5575780B000104E803000004E8030000C5576D6FDB3610FEEE5F715031F8058ABD76DFD2A1401A644B00AF059CAE453F198C44C9C428522029B742B1FFBE3B927A4BE2025D5A5440ECE074F7E8EE79EE8EF2663583155C19A30D1C98CAA55025E037485D96F47FD1A8CC09AD2CFA6D66B367A250392F607BF37A7FB5DBBDDDEDAF67CFD020149FD8D05165B2C939FC6E5DCE4CB93EBC9ADA849E9AB8312A9A0A7AC2F5C5FBABFDEDC7DBEDDB3FE91943686B3137EFC8A5E5F8E9934F6EBD1D0E9CE5DC40212407A51DB0231392DD49BE4ED055E5A298F50963B2B7EF768057E24192F19DBF2EDE5D5E43F449CE2119E23E5CECDE84C0E413330A694A26F74268F48AA1A1A8FD3EAB6563E96FC63F3B6E142497097CE9538BC60C0977209403FE59B87D81353486BF9CCD362BB8A96A6D1C144657E00E1C2A2614D4469786555020159D7475636A6DB925E126B8D981195851886255447DCF8C209A2CF842281E712A6E2D2BD178E4E64E5BE15A701A503DE46B83F73DCD033C251C5D11766C445FC98F5CF6D63F6EB657B04224BC83191CB5C8BD5765CB0546A493545358AFD74B648F3967C45DE3F87EBF5860AD1573B0A80D061429BC48E1B7E572F932801D4F831DD95E0AEBD0130BDFDE6F7458C4506888BCE88C655887BD05BA006CE7A6E258964739A70942140B0C225F0349344B9BA009719542E8637A60CE1CF7A3D6694762A40496F39ADA017DB4F21277EC8133DC1EB4C4EA986CB85DA337055CC484ACCF8508EF23F00A133398B0027710960C6731610A0BECA0A1047FC55B2936580BDDF805AE4137AE6E1C440528926528AB85F92F73C242B900ABEEB8035D13B54CF6D459DFA90FE2C3920999F891B4A8B72A1753FD1E48FAA0359456AA911216CF7D436CBA1517E0A0E48A1BE6C6B27BE676DC35469190B5C687E01E412119E42D4A233226650BF8A133542EEFB0300FC7C2C090543E6BC28AF43D2E5148DBB5350F5C472C52866CF81DC3CFE3024AFBA58355648D75BA5A775AD3E66CAA0034F76B741EFA83B2C71EF654F371FD41BE142C77F0AB6FD67F44FD580F0CBA6599AE6AA65A0A1F75792E7099B13640BDF97BBB1DA14D19F5D0235A89ACFB64AE83FE7E7EB13B43CEDF671D042CBC9E0497E299627C493D703C019E083C595B3ED7AF2DAE93EDFE6204D455FC3F811E29F5D8D5FA84DCFA51A4CDD7E18D772F6E8E6FDEBB2ACADB35E6B064276DEF8FCC38217E7A60E832EC7585E32D09AF9FE31E90AA382B98C349F0379621BA6F2A0F144EE31841E5D1D96DE1937087C9311E62FBBEC1E9C7C50F0C976797CD3C05A42F2C5B3447D7F9988B79703C7900FCC0A5F0930F0658F9B581592FBE7DD89EE3BCF93E0C41C713509337844BC3FD510DD959A4EAAE3F07C23AACB4697DDEC285BE36C2DF411285F3477A63FD1B5920C9EFF807257EEDA4F8E9E49F3C1D1F5BE3FD4F85FBAFBCFF0EAFE0FE1BE8FD6BF8D54061FF01504B0304140000000800B6B20B478288486FB30A0000A31A00000A001C006C69622E6D6973632E635554090003A79FCA55C39FCA5575780B000104E803000004E8030000AD596D53DB4812FE8C7FC5E02D40068381BDBBBA8278AF0838ACEFC0A66C53244528D7208DED4964C9359260BD09FFFD9EEE19C99243727B779B4A616BD4D3D32F4FBF8D5BBB35B12BAE75E2AB3094918AB344F8F17C1E476292457EAAE3281193D888F3D6F9DE9E5898786AE43C39C02EDA78234D2AE28948674A5CF4AF3F65C154891B4B34D7D1549CC751AA9254FC33334B315C26A99A0B190522D4BE8A7C1510932C0A94611697BD5B7179737520864A8941E7ECE2BAC3D4E7FD9B0FDDDE250B12A854EA902568D56A3FE9C80FB34089BA1F47133D3D98D54B8B6F923408F5E3C1EC97D25A16692C57D792D440DAF5B5409AF5353D8D64B8B6B64C5ACF52A7D5D5891FA54C5812914499C3D42464755519131B96BDB52BCE8C914BA1A30036B2C6D7D1224B5B7196E2434C74A86085C4377A91C62611321159A202F1B8140BBD505E832CF353A0263A8233BA379D71B727C45175A97F3B1287B51AAC06EFE82805C7C9182AEB783C09EE7F7E106DF1450C4717DDDEF85DF7AAD3EB37E909BBCA8F9DC1C03D8A97D35AED29D68118CB5099D4B38CFD993462171A06DA3445796D9E4CD3E542551773AD80BA46ED4B6D234965AA7DFB328A23757F4472D5EBA7B50DBBC19F07F8CEE267F3F9528CC732852B1FB3548DC79E974564984603B26DE889F044E98076BB777B75251AE53530A763881C9CF124C330F6010EAFBE95B45831B1B395ECD83FDBF5A6D32C57A62C3FE40AE329DE7857FD4B78E05DBF5957BF293F4B292E8841BD89435836727A42D81246A59989C4930C3325D2D8A9F5248D968F21AF18358F9F1405E9024030B50D44D0B33411B82607E24EED1805B18D92C152A466498761D75445CAC814AF72E2538A38A37612E610C5225151A200859C9676CA2826AA7C8F789EA908FB7422A6FA09E09411EFB6F0A5AFADDA8615B92D128E762FD7716294720F2FB51AB9CC5A4355A002822A247611834993111AADBE96806A1720C131E28351B3D0C138452810A7990E8331BE3A94180577293F758F84AF2C710F143B96E5FDF14381303AFFC951E8A6C0F6024C1EBD6A7B8EAE21E68C16CF6339F78E1BBB89FE5DC59382A0D12830E7DCBC7F5430730AE05DA1DB3181FDDDC5A073D11D8C7BFD5E8788730DF0CA5B911E3E6CB6CB94E2EB5778A3FCAF203DFAE3A4C7EBA43958DF66302B676C8261A80857669ACD158C1422BB72D222F73E2D181580A5F065641DBBEF4B50D0E6450CAB2A039F26C886CAED1084AE4C1A89772810169D2981781E077AB2A4AD00AA17DB9A11C8543A4E10296EE43024E7C02E6427EB8086B0D902B279BA7D782AF41BF614BEECED3504D3EBBDA3CA0E7A7FAF090DFCDA7A9649C891CE1AFD058282D0639375B75FC08C520AC9523AF267771C706A1D5F585B3FB40B6B538A16DBDB369FE7C0D40F8DCDF62110328D390FA4638E3B088780DA489E75EACFC0B0C03CA4C4C19F510FF838985D017127A2E5029645B37149DA51C6DAA80093778843DEC15CA9FEA3262576275651DE2302A3D51E5251EF40159BB48A5AF80B4CD3070EE44AEE87317866D8A502F86B12EC3866DF31D17FB291A32259F84831CF00AE4702264BC698B0608388C296D0266FB1482FC95726E48A7B6245DBD880370915BA0DF3FF63553F4FF2EACAA673B206D9E2B8E4B27BEC7D68568A2BFCF8E65537E62CD848EB3CBEE7FBEF6E3ADAFFF1B697D7CCFB0B537F5953A744F03FA952A6FFA13C2F1656833CC9AD3C635D651D524998881296B1DA9D549A93D765CC8F5A8412B9C7E21B31342B30CC67D99C4485AB5904897C8CD1E1703284356416A61C220B6928019662642DBCEC8943959642E19B6EEE4F8A8635615CEFC8D1E14223C73B431D4D7C1E14450C503893559A2CEE13BA51F1846C2D39CB5542E7478182DEF3A408191728250D40BE06F43F8CE952AE2AE0933B95DF804712CF156564D4943C29DB948014B1EAA864D07A363A5DA95CC25951708B034B4D853DEE0EDD3F1B852B22EFCF310486E8B97532B31C9F67E46EB40E363DD3D8E06DDB2EA401ADF68F6CD20F36DBAB2CCE366351D65F54DB08926444B3169A346EDA7219661810AC10505D3E46B1A14E6559D27153DC75DF75DE77479D0BCF4923CA88C3DB61F7B277765579EF4E3F3AFEFBDEDDA833B80649FEF6B4B275D4BFB9E95C88EF6CA5D7EB5B73C58E4F5D52700B7724E4707436BA1D96E85F6C1D1E515F9ACCE20CF68F14A04A4E86737DD29B942D71E50DBFC23A219124716668D67A54F0A272D251BF8BFA5D944AB14A1E27B56AD92CF9A1E86D756A87C55005F9688485F18CCF447453FBA9A7DCB096E6848BCEDBDBCBA6A80F79AFD80A70A8AFD06B07F526D39F964B3D164AB51D4624379CAC1E7FBDBD293D757BA313CE6825D100420E9F47D8E9339BF2C5090BC038B2C473C398C97C165ADACE2691D880C704664177AE9EE732F9DC147118D0171274FDA84367F82C220A9AAE843B82FD335773F0F2B60B5687A433F7D06E8946399704F594721B2D7AD06D3CEC8CAECF86FF6A8AD5EE6D27894B170467F69E87BF51DCAC5B29C8CD4E887A0EA6571CD245E70A7957D4C2799277C10EF22091B977A1EA76C9D9A7F96BD6BA9D9BAA589E84729AE4E6C9B5B346F69C539BDB896C52CFE994A928A2BF275BBD6CAE1543C042FCA90C81ACFF83212C5EB30D37B21AD5C353BE0679E7EE9F4A43EF4DF7C2164CB9AA6C84B103820FA3D6128E1D230BDC2CC2C19F3DB7660F64E240823A02C02A2368BEB93A4BBA1170826A3897BF4D827C404454DC1FFDF5A112963FE8BDCB561175CC4434DA10A513860D5CF4DD362A79285B6FC14F4410D35C34239BD2207F6087EFBC1F19935DBCC3C6A9F8B6353959192DCF9DE733E57FE63A6F0B21599A6B178C4D64ECF3DC329BF9184B21E5D668E04F0D3A316FBC32B4AB01DE2468C71892721734457F3CB8B81B7CED8FCF079DB3113E3BEFCFAF10EF7FFBCB61C3766B5C7C5EB5960FA3A4D4A2D873ED4D8A281F4A05235918F86B822A61B0752BF81859A29554ACA8470E651AFC0921223E2041E9E175592652534A231EE48092B9EA8508A5166612BC1215D0082F69FB0F7481AAE4C82AAE4B45AF17A734136709DDD250F76A71C412B9724637A63EE36462E2B9188D3E58D797B25CAF3FEA9E7720511E127CD943EC884F1B75A8B05ECD3658E44F6A02BFE8A88946B009955EBE6D66619356A09E5A511686077CCD70EE54468732779748B6C2BAAB25952B802559853CEF4F8DB69366B56B2376072BA4A23A33E0EAC5E990BF6EA886F294D870102EEE3E5EDFF06C37D0C5D27FB5011A352A41F22A904D61446DA153B557BDE4E5739E15A85EDAFBB875435BD53931D99B37BA0DF7C6C3F371FFA6D31B5F9FBD6FB89B0F8422268A49F0C666317CA3E1A240A9F3EF30E58BFDE7A848B35313678BA6C3124DEE0425192D459A2E577647F94E74E0D9107E556950E41EAEB07685C0A660BA8E876902E46DE5154BB60B41BA1EF355DC27BE55B483129E685AA264AC1F367970AA5CB26C52F3697860DAF918EDC08D62F56C761A7CED66EE3FEDED3DD844662F7DF85E85D61FF2EAEC3A3D2CAECA080D455408CB45847E28A95E6412952D293631D53FD6B612B1BF4FB9997F43297E3F71FCC456F231FA58BB03C453C0E47159FD95053051210064880A74C50BB4FD401207EFD9DB61FFEA76D4B9FA207A7D717736189CF528FA6DAB8CFFD4C562469AA4CF281076CE5BC619B1C3B378562131B3D116E8C4DDAC0B4C3BF6371B5F99546ABED70B34FF5604DEF4DB8DFB3187185DF26D72286EB2C750FBE2CAFEF053F929C7E666B6185BE9D4768E54BD60E47F03504B0304140000000800B6B20B47C5D0B12A96050000BB0C00000A001C006C69622E6D6973632E685554090003A79FCA55C39FCA5575780B000104E803000004E80300009557DB6E1B37107DD7570C9A074B8E24376E9F922680E34B22C0B105C96E0B048140ED7225C2BBE482E4CA568AFE7BCF904B5D9C286D17B064F13233E7CCF00CF7E4B843C7F449B94C96A5D0D2348E3253554653D1E8CC2BA31D15C6D2F9C9F9CB97545BB3B0A27243EC3AE9745EA842E7B2A0EBD1FBD9A7D1F47CF6B1F302BF9596BB43BC8C57CD66595D368EFF3AF2C94BABE9A7F39FE8AFCE0BA97355743A27C7343AB9252B736565F04DA6DE86209F64D678D9EDB1EFE4E7EA627279319ACC6E6E6F2E69F0EA9BF1F1688CF1D360FC224E3D5A51D7D292B0A6D13979DBC80D583A9A89525A7F44DE90284BF348B5704EE905F30450B049C251F49293D2946119E61337C3DDE882AD6EE5167E5DCB7E2E5D665540D4A3E8A71B4DF6BFB7A4D3591995A7851968F0942D85A5E352CD41519F76C79285BDC13D7384673613DE5B35078FB359B7AB8DD64D5952F7559F4E7BBDDE1BA6E932F24C472D1348D802385B7C4C0CD843422A6A1C6884BF422D1A2BE625000716992B70A9AADA582FB427B7765E562457527B37A4A994CCA0684A1F29A218664873652CCF7AA1CA54670A2652F677E1ED83C54F2C0C1F9F7FF912BEFF3F6841AE99036A269D033E4E2C827A20814AE1105675F837D62532BF4E6430E6D1B3E22DC8F95CE9137C9AC6F397B49631F1E233BB682AE6E335FF8A10B22AA7F6E153C89E40F75C26F43975C767771F49397252D86C29F3DE76B7B00BF7F94BD82DAC156B0E40242F6CA8B5C93B9852CD1B923FDD547364736F8BAB65A60A25373B188E991539F825BA5225272AA6CED8784803E03E45C481AA881AC4B035AF56B25C3305F49DE752644B9C270D70B5B0C263298377D273F406070AE1F9258EABE1A389E4BC3E60899E0903E5461F797CEE26E85FF746F1E022D3D8112A5FD532A2424C2B51423A305A808983C69E3D5BC2188C011A281B575444C60E0E9A2A727AF7967E8E3F06548907B85FA21804E54D5DAA0C94B1A1DF8AFC5D4A19B83FE55484678AA851FE83AFD21A0E3C91B1A9B63659988A191CD21F4BC9F9F00782E298BFAD79B6315F6FCBE5F40B97AC5A689CED3C1D8089F48DD5B1FC6F35071A8AC89A2AE9054BAB83AAF3661B56CBFC358A5D660FBC5C9BB62F782B80954FA1E02086AD45C047931165323D38DD3594C20800F55E61F0B29CCBAD2B9F32D9EA524B648F1E85F2B1D819FCF69CB231A8BE72CB5021D18F4378CA67268731EC980BCC96EA416E87E14ECC35C75E268D654B08BD527A836713E977C2EC6F7CA9AAC2743C38A28009A44058CF2AB6132BDB7A547E190B2E6ADD6074914A305BAA324F6B5B050E9D08D8BC431245E9BA51354750DF9023C86698A025F640D1B98280249345C31A99C0402F84E4CB45BA4870284D6D185626D58A03BDBB9C7C1ADD9CDD5DF6E9E3D9CD87FB7160737483F1C9FDF8AE75E4E871A9A016A8CC60E4A8BD51C45691E22CA1986FE9D5D190EE00CC9552D6B83E705981007C88C61BAE191E59B3994824ED0594B0ED521161A8AFFBFDA877B8D5A43E738566E202226E71286517396FAC85E4A66C84B3D968BE6988D617BAA6AA54296C280E1376C59984A886C4B20DF4EA6BA59BA7E0E5F8FDF4A24F8887BB7189693002C9917D36339799400F27E5B994B4F15BC5E7E33BBE9D8EFEECD3F47EBA3A2514EFF477FBEB8FBA57AD7256429685F42F379D705CF9B80091664215578D06CE10E1A355A88BF1E8E2CD018969E5FFE6FEFA9ABF394C0E5A242729A44B15C4349D05D7644C652CC020137C6C43DD8B566DDA8CC6E81DF256438971994356FF6B3E27C8C00A48B071608A016F0E6CE022242139DDF34900797DD56B950DD6F46298C48FD3186E4B56E18EC50A60826AA50C57268FE948FB3615B8827968C00FEE433F887EE7E233B6B1B1234A61F3CD2D4F8B2A36BAD64F3F3297E34DA114AAE2EB33263F8CAF397A741EA9B98EA0C1C39DD23868AD85B3F31EF1FC05E1EFCD5B41FCA693E39D770ADEF50F504B0304140000000800B6B20B477FE4326DDD020000F005000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300009D54DB6EDA40107DAEBF62E2A092480172E9130DA922421A54352070A44A558596F5186F62EF5A7B51A055FFBDB3B62138E943559E76D89933E79C99F5E1416F2964CFA44170084395174C233C6B5614A83B866B5158B00A96089C6519C690689543DBA2B19C195C6827BB266D778343AA7F306C857D689DC2A54F8899655D21AFF622E52C850962BC64FC69110B4D215C165AAD34CBCBEB12A9590F702B3262A0A465420AB982ED35085938DB6D54943DDE56A43ED41AB93D8147A7374079DBDAFDFE7FEB46B51659DE365067BE149774476B610D18C7391A93B82CDB00AE399277CF294A6092785AD49265805A2B0D8A73A74D17E66E990B6B312690263408E3291811A326DB6BEA155E2C92C473F53998177603474C7A0853201789C0F8B81A489452463D453F3F435414A9D1BB66345B9E227F2A356A342EB3C65B32A46C2FDD6CC88575BF44A35F6B78371A7E594C6793CFB3EBAFAFC7DCB0B139909A0EBE4630A972594C9DADD3B21E125925C94E95C0E556E91511F5FA2CE9643ADEDA0F630BB93396DC16E48DB06979E22A46F8895A797942C682338BBE7C37A04A3409EC06C17C381B4FA341EB48238B49F4137412085BA7E1717D35BD8EEEE89A9655B21CE9AAFA9BEE1B5A0661EBD74BC1EF5ED96291648AD9D0BFAE4961050DD4732A98312FD6D7B6F56BB8C9341A4FEEE78390AAA2D13C1ADF13F259589E270F1105E7617033BEBDAD828BDEA38B579893307A7D5DBBF6DD4402DFE1003A6B62DB2019C28F8FDE6619BC439E2A08477E1FFBD06EA6B581F60412E52479ADC954E4CEB26586DD10AEDE9F07EF9EB5A0852EF705C27163B94382F6E3380B12E175CF5C35D89DCC37945A0DE144B9921D42A73E9352EA4B412D3B0C46DFC6D17072331AB43E05F503ACE69F3091398D27D54B914A76CA45D8AD45A9A95F19D4DAA24047229CFEAB351E8B9E6473DD7658FFE1D0B05C833A97367CFB1C761DA06C411F65AD0A2D6899B34D2DA163F65CD913E08B3E5C049819DC46E7BEDB1F504B0304140000000800B6B20B4739A2BA75B60B00009D2100000D001C00636865636B5F666C6F61742E635554090003A79FCA55C39FCA5575780B000104E803000004E8030000BD597D53DBC819FFDBFE148B6F009BC80ED6B5D31EC46432C461B821C090706D276538595A615DE4954F2BE3B8777CF7FE9E677725F985975EA7F53058DA7DDEDF77FD7AAF298408C732FC7A1BA75950886E574CF3EC2E0F26A2C844984DA6412E45362BA6B342444111604D1541A21275271845F79A44E432C80B91C5A2184BF1FEE2E32FB3E84E8A4B436A42C0C7C093BA103FCEF285F8B4D0859C884045224D42A942191191998A64CE244ECEAFC5C9E5594F7C92525C0DDFBDFF3864E8E38BCB7F9C9E9F8838CB452421484AFC09F7F338D1A5EC61A0C4488A999611E9C18C7596CE8A24539A5600384AE5448BF9584241B0241A564FA8A8135D68D186F64512A4E9A243BAB1BEA4CB344B5421D46C3292B9EE8961108EA187621AF3244D8977917D952AF91704182DC025810CD320943DF121C9210D29C920BAC4B0D6664B045AE822072F903F25AB42B998B4F508536D42072EA90B4CE31726039339B26214D07EA6442026C1B764328303D2349B633192F74940C611719E4D987A2E6358069EA91986C8A9AC201AF25B1016A0538463B2880528652E4D0290050799091B3199A545324D9DF49E18CDD8185A3A7B0204F68142F2D75990B2A7475931262271924A5D2A6402EF5A4B631EE77B3001B35F662A6485E6493166855A16EFD602F6F4B84504749827D30266061EEC41DAD4E9C1E0F34C6453220671CC8316BBDD6E30D2DD692EC35D6769ACE532356B2E04EF927BA93C0A0018444F6598C40B16C7B9A0C85299078575FB88A3543239D0824FEE65CD3B36C10A192074ADCD9DC708BF749ADDB4C1236D48084A6632086C24F125C9B4483A13550BDA36C1A7671344053BA0D7147BAF9BCDEF1215A6B388CDA8E2E4AE07E3355FEF890F70CF38B827AB056128356757A263548842B63B5033CC33F2094265DC1B13ADEF22195364DC9E7EBA38FEE187DB4F17D757C7C31A8B37BA88D264D41B1F2DAF25D9DA5290DF2DAFDDC9022E5A85A3A85C5E33E2D457649EAB150661B1984A5A2A65BEBCBA38B97AF71156A88A66ABDCFD6978F5E9F4E29C0AE08FD7EF4F86B776A16E3E520CACB29C2CB8BC3C4974C87675F43EBEFBFBD9E9F9F06C782EFAFBFE9F9A4DF9AD90B912547D58DC43F6C167E7E0AA3691E062CE1590A0814455EC80CC4F5BA02FD20CD05136431D04766148BD9771800C7D241029B2138D40644254260B42458032D62DB06E09460C447FD8FDCBE10610D05A06B130E138C8C51EE59C0A26F2706995D2BE4FCB9E79F60DC887D3B3A1DD741B20171BE999C921BF3996874DB24C72A7321481B9062CBDEB7136BF1DCB747A58BDDEA30C414B40207466A87326EB85118A0C778B15FDE5065AFCD66CFCD672A5A0E581DBAFB304D5E916A1892C528527CEAFCFCE3CE13EBBC1EE834748AE56BC0829B74846FCEE5CB73C95D5C0CD6705696E9148BD9659DF80B4539A8057FAC220592310DEA34816C673487501F62B41DC67593CB12F1E9A0F30F27D964488D4E00E05A3097B4E91AE45DC6E5DD3D281D8D6E2CBC5E567E4D14DAFD7136F4E4FCE2FAE86EF8FC41B8A80BEFDF68FFE09595D00750E2B32C7768A710DC2D64DD4248A99920A378AD5020A2890AD53AB70FC236E4E9BA70243CE94C12A6F7A2BC4FE46BD3C5396E0110AA76918D4C57FEEEE7A2229682D974164EABC2E9090411E412E2AEF2BE4B810F078E1DC55B316E898E0894CD3551265206215B83316C928499362B14A74E555886EE089AAFB0D2EAF86C7820B0D3F057A43BD106D9BFF079CF59D759A39D17419B181665990FE039A73A259268C8939F35A1BC84494C4D6E77A8D047DBA5D4A8D5A1447899EA6C1C24C09BC4745527E4B8A47F06D96387C1B596E355170C1C4F4F74708D957DA69EFE3E9C1947D9A6A6938712147AEE49E0D2F7AD48ED1DB393269E3D5EBEEE9F907D495E09CD954764429E78642986D2A9831EA297FFB9C8EB6A2929DA852A5F480AC6D50F737F17D1FA43369A68B72DAE4F8D7D944DA0987720A9C1A492CDAD58010F73B6267A7F6EE7744876A6AC37244858DF108C1FA5D6CC20A0D2B42B963B75E97DBC50C3D72ABED281C95FD805839ECA3B22F10D683D1878C03A79AC913830CBDD7845681AA24E61716D772EC5BA39CAA78CD2C8662C2C358920B8D3034C333F66B0C100B15037E29ED6199605BBC41E50444ECD35347FCFE3BAF1E95AB78AAE9F4939102E5CE453AFA6A8A19CF8A16A4F360A1ABCD1E0B64D9EDBB60BBA21254CB1A5B8D729A2E3258407BD60CDA8623CDAAD4BE714CA0D8E41266234D6336662AED7A970731CF3E821C471E014F330D4F438E06B8A3F492990C3210BE60F7A6B290E67780BB2D8A077CBF7A65CD5103218A5649ACB09AC46E82434A9B1E50414327CF1E5EEE4B89D0FA816B0796223F34AB74D851D080CF35F460F265AE4DBA187802EA7FA9C6BA1B8F97FCFA529D360D36F8F20F4B5B6005FFDD0259B5EFF197EF098547E53B7CD860851556563995E9EE1F3E9EE8AEA9C26A64882FFB3736D22FE9C849293F4145E9F271CF9D8F28866AE3E0EA84C8C64F5777AB49AD518E69D655E58C42DEAD8D1E761B6C3110AF044A1BAB583247825B1ADBDAEC5552C26B0507F9C1BCE595D39CC76EDFEB20793A5B836EDF46954621C3D1AD4D9AD9A5100769B17F80520E1B107E3753E9C20D89A479A331824FBE1E3A60CC7C0704BCA18B19F09AA9E02554CC888487A0DE0EFCCF75CDD4080A87ADC13E253D9E0683B68995CE8E01171D826CF001A3CD4704AF853346968376B189BD399226326A19262B72E746EE0D1DDDC85D73E2FF50EE0DEC9F917B6EE45EEFF6CC415BE9EB41D6DF44E6C090311164700DAAD97EBB7BD02CA5DEF75A33F5556573E52201C038D2693E1BBB79ECE7ED70B7E501007F2B92BB716689A4656D2A15DA6A5952917638371239F1F66DCB637B761CD1072A77C6F055E274DC8C7D58DF7279D4710349DB9E713D7B78ED50B2333C25CF1BD24D45AFBE07422924DD094995CDEEC6A5A276906D317679807315C412E973097227BA954DFFA6648CD00A27D376750E6C755B9DC180FB5D6DCF5FDA33B95ACA487748F602A98C1D73CD569FA85BAE713ECDD7D0E6758EFC28518427648AB0A02D466F3B80389B4A552793B73AA043C7A1D28C36E8D11AF9860D0862775B23564A3423DA9A649BB4E6F5E724F39724F3FF98647E2559B3617AA0ADC27646E382ACAB97AA3CBB0A6BB0B84737A8E79158087BDDE66EE9550DCB98A263E1FC25387F15CEE7C833EA1255AB142286704B156DF63D0EB9E52049D47222E75EB7FD7D7460CE907D843F1DA64632A67AE3D319CA337A992427FD8D8655BE3FD4996E6D16EF29A6FE32D3FE0B99E21F4ADA31DD5F8914830395A75A81E4F2A638ACCB31CD3882060A26ACFCB55D9F76CDFC5D8F4F42313B5B656CDA68B08231F45655882DCC069D6B32A2AAF2F02C02BA28BE4BF8629420D74CF0E054B663990D481A0A4945D5B72FA4118F4E6BD1E930495ED3F1307291FE6480B8BD63463AA277E3B5B675AB321383FA2BA03E81FA15A8B1596333B53DBD0D7D76547F1DA8A2E3802C25D6EC9553CDE8F6CA2857DA9B75D81AF4CD7908420E06FD272C6F439C7A19AAE776D4A51B75B24ACDDC9E359311A21E7A55ECB1376A120C6A126CBD448231EAB5FCC6B7CCFF9514F4BFCC013A94995F52AA835AF5F38B9B143606B529B87719FDC44424A24CC98D51C228ADEDB3188E8A374707112C416CF15AB2D5FEB3F6F1AC55D07EF385B0F57AFD9721B61713B217127FD883FE0BA4F2FF2F5255A5A4BD165A78EE3C21A5914E65AA6B7E02B5C160CEC307DCEAC4D680BF9F91D1AB22634DDABA88EEAAA5EF55C7FB65D51E93D2486844D358FCEBD909C9B6DDC5C39392195E86F84B6F601A4F5DC2349EBD87719C2C8DA3F288D311D50559C560FB87DE9FCF862DCFAE2C91B09C8ECAD3469D4425862361572C8987258BDAAB34EB1051E5EDC15251A8359B20A669DB4685A9062BED71A96A57E57FA54D2E95ED2A489E6D97CBFDF2D186F9D28EC9DAAC564F43E1A9C47B28B3FF990643B7689998D044626D96297355CA82D5CA69CD6A7696AF59C85496FAAC440E8BC334D3B25DCE81B577BF3AA7D8FBBDFD5A987CA09F39A176FDB697AEC4B623664A37BF1EDF7B18E5BBFDF290543335249CEB1A7132FC1A83CD37CBABBC0C9D256EE67EAABA75FB37504B0304140000000800B6B20B472BA63C4696000000C800000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E80300004D8BB10E824010057BBF628D2D0BD1DE4A21A1C2A0C65891633DE0C2C192BD3346BFDEA390D8CDE4CDDBAC93DA8C89EB562D11600B586C016FCA5AC0C679453D4EC25E9367013C5659515EF2EC5E9D8B6B7948F7BB509DF2343C1A9641F905D0697A8AF16F40353A0338E9871ABDA1E56023FC44A2ADF04F467E01759AFAAAB1AC7C1C5A3B803575AC455882CF3C1847F3C4FFEDEA0B504B01021E03140000000800CAB20B479E3BA9076E01000012030000080018000000000001000000A48100000000636F6E6669672E685554050003CC9FCA5575780B000104E803000004E8030000504B01021E03140000000800B6B20B47ADC6252E89080000501800000B0018000000000001000000A481B00100006C69622E6572726F722E635554050003A79FCA5575780B000104E803000004E8030000504B01021E03140000000800B6B20B474F26481915040000910C00000B0018000000000001000000A4817E0A00006C69622E6572726F722E685554050003A79FCA5575780B000104E803000004E8030000504B01021E03140000000800B6B20B478288486FB30A0000A31A00000A0018000000000001000000A481D80E00006C69622E6D6973632E635554050003A79FCA5575780B000104E803000004E8030000504B01021E03140000000800B6B20B47C5D0B12A96050000BB0C00000A0018000000000001000000A481CF1900006C69622E6D6973632E685554050003A79FCA5575780B000104E803000004E8030000504B01021E03140000000800B6B20B477FE4326DDD020000F0050000030018000000000001000000ED81A91F000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E03140000000800B6B20B4739A2BA75B60B00009D2100000D0018000000000001000000A481C3220000636865636B5F666C6F61742E635554050003A79FCA5575780B000104E803000004E8030000504B01021E03140000000800B6B20B472BA63C4696000000C8000000050018000000000001000000ED81C02E00006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000800080077020000952F00000000, md5sum = 'b3ea4bc81909fd7874589d77b0d1e29a' WHERE execid = 'float';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B4759934133510100002A02000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D514D4FC3300C3D2FBFC274930687757C1E289A00D10A86D6156D4C1C51DABAABB52CA992A00D7E3D69E92686B8C47E769EF39ED33D1AA62487A664AC0B4FDCAC5008C8D4BA2281B0D1BCAA500F4CA6A9B250280DFDB6E79BB2EF3BCA1C116CC92DFCBA633EA5E55BE03287B5D208240BE5331646F3D791D73BF3E0064C49856571144FC6F1F86FF57E3C9D278BD943D4D46B6183372E44D09961A5B40597C3866B497269EA6612743A4965694D5F586363B9A52CE8CC9B0882E46A6F4D50AAB9266C88AAB2627FFB851B03FD16F6C1F54849B0CAD9C36606EA3DA7B2A5469E07D0925AFC3F0B8E8D5B5288297109E9C712BA57D71797A7E7276C59663FD6DC591B725676EA0FC41DBE0A8330994EC6D3E8FD79113E460E8649DCA60ABC5EBD67CFC53B8FE1966CA6721CF56EEB3566029D84CC0DB19843E1BED1044CAF6150B4345F791073927E49AC21436F37827D03504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B4759934133510100002A020000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED818E0100006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000EC0100000000, md5sum = 'c89c2b57d8c504d2b2260b727a4abc35' WHERE execid = 'hs';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B475E8693F037020000A503000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300005D925B6FDA4010859FF1AF9812545A2976441EA9485B15B722E25285A0F6A15232D863BC89F7D2DD35842A3FBEB33650541E00AF67CF9CF9CE5CBCB95A0B75E5CA28BA805BDC22645A1A5111EC2C1A4336769915C643A12DF40FEF1257F613AE5F12812FD1C3598DDB2B8F2F802A07A92D815085E65AAEBE2F853B561E841C20388F5E6458557BA8847AA61CD810DA3DEC842F61933D2530D7BE6DC42AC70BB025EB8456A00BBEB7E63A90B5F3B026E0294485EB8A2E61578AAC04EEABB407AC76B877ACE14B820C1D25305180792E3C0B5D82F06049EA2DDB725A3201B44AA88D6B670C1D36A4C8A2A720B2DE434E05D6956F9D1E6CB59361504C786472673A256EB9B15645ED280F3E08A563428D2183CE2751344E97F7A36E6FD0850FE04A51F86896CEA693D9E4FFD3CF93F972B1BAFB9236E751743FFBFE75324D478FF2D9933410C75E9A5C58C8B57CAAF30D3DF0040FBAF6A6F6C9CFE6F308AFAF402F3CF720C41FFFE014869D3B32DA065AD5C97978B9B81E763A53DA5205D7A08D1752FC69C674F0EE08A259004394BF0F375A22C3CEB22513D26D510569CECCA2150DCAD80843C3CE8A59857FAED16190B256BC19A107C7EA77442A50DE7001877E063A0AD934EE83CD63E3F8B0168D3AE39028D468C65F108F17F3E9649E3EDCAEC6DFD2D1800FC68BD9E94143B71762E8F2EFA72EDC40EFC016AE6FDE0EA2002CD3398D7A1FA38D2526BD4DA16FE9772D6CD868DEA25A311E6A6275255ADEE9D3B8AFADAB5F09F64FBA91951017FF1E9B16D03B368AFE02504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B475E8693F037020000A5030000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81740200006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000D20200000000, md5sum = '83c7b3b581cc606b16ea752922a75930' WHERE execid = 'java_gcj';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47A6AFD52D92030000A406000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D54EF6FDB3610FD3CFD1517C5AB93AD521CECCBE0D61B5C5BED1CC4D1603B59806E2818EA64B1914881A41C6745FFF71D29FF5082E5831C5177EF1EEFBDBBD3938B07212F4C1104A770C5360CB8AA6A51223C6956D7A823C3B5A82DE44A437FF72D36453FA6F82522D88259E8C4986769D91698CCA0521A41C85C512C45AF0A61F6910FCF16A31D9A8127610B02424835E354FA6CD9C873F84A6CF89E8EF6886B94A8994543700C4C8165B947B40A742341D8239A03A0FA1675AD919E5052AA6EC9DCA4ABD92419521C913AD4D8617126A52292088DC1EC0878BB4CBE4CFE58A4E98A10B892B9583744472809AAF63FB6D19232947C0B8DA4AB19A8B5A22ED20FBE4AC809C381F2422B2A867223B492154A0B0533541C098E3DD29333EAA3CA4F82609A2C57A3B07719C23BBABDC86D304FE6D7B3F9ECF5E97876B34C6F1793C49F3B6DC7956A085AE5502109F30C1A0DEA0D9175AA39225E7D22611B5642C57821A4930F1E3FC4A41D124686396B4AD798523D0135EE6B632CB007B5418F50B1ADA89A6A5FA1316CED88036FB4A67B11C206B5A1DB1B77EA25DA546FE1A1B1508975614122F111926B6446C8B5AB6E54453D62064DEC2EBB4896C9E22E998E7E19B83F77B39D69BCDA0EC0404E624A4679648A8A595ED093A078C98C19FAE64CAEC7CBE5684EA741D0366A3A5B50AFBE1D3BF7E3C54FDFC3E03384BD434008237A3D8684F00FBC790347807EDC0F56F33F479D9C8BDEA11EE9C0EB5700618FE263C7DDABF4A13317C3A09D806E48723F5B4DD26932EAFDEEA9EDDF438848AC41CB07B73405874F0E7652207FF442FB1EF8060D0391C367388128DF95F0DFE84EEF9C3432F80179A1204CB4567AF86262B30E0CF48FB97D70639393D1B238A47CC7E332C885A7C04ADEB8016C7D4663B1D6CC5BA51415C591E5F75E86C8392986ABBBF90B2B0D0F6EBF1ADF8D47BDB3B34E46C71BE7E7AEE05F5A5031DC226FACF3523BDB43FA92F833DA3BDE32BB8B65F86255F899CF55494677C9ED78BBB513DD57DBE1C1E946FC8B9D996214CFDBF9AE952A03FA1F7EA3EEBAB90DE1FDFB24FD189C1E36EE297CDAEDB3ACDD65D17197B5BCFF67872937128DE618BB4B4EE98C5BC884F67E773B92174CD2D8D191C3A1AC8D5B29AD600779009DAA3452DE03E1DFBD6F03EF773819B9B741C7053CEB7CF7623A6E2DB1E8DE985F2BDF131A9D8E38DF1F219AA637D7B39BE4CBD5EDF45332BAA483693ADFBFF48F63D10F5C5B025E542A03F6F376DF2F57888C3108FE03504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B47A6AFD52D92030000A4060000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81CF0300006275696C645554050003A79FCA5575780B000104E803000004E8030000504B05060000000002000200940000002D0400000000, md5sum = 'a3722847722e061737c93d89cc9fc87d' WHERE execid = 'java_javac';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47CD775514EB0400007709000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300008D566D73DA4610FE8C7EC5462691712361B7D3990C0E6D1D50523C603C06A79EA91BFB7C3AA18BA53BF5EE84719CFCF7EE9DC0C86EA6537D00B4B7B7AFCF3ECBCE8BEE0D175D9D79DE0E1C9325012A8B92E70CEE14294BA6424D152F0DA45241B03E8B741644A83F630C4C460C3474F4BD30640544245048C5808B54A22E6ACF33AE379A37F786856B6B1AEEB8C9D01083A922145DEFCE2AD181CF180DDD84A3AC4534B260822962F012019DB13CDF5834125425809BAD356B00FD1BA64AC5F01372BCA86CE02303A43232412935DA2917840BA039D11A0429984B4096864B41F2FC1E14B3D25A55CB4A518666525B279E3A617D15332CAB9B9CD33AE593E97C34887BA880078F99AC23A6440889A5605069966CC33E9FC55783DFCFA6D3395AA052A47C5161CA18C93A2030951278438AD750092C203A55127B855FECD985146DB8F03225D119134BAEA428983090118DCE199A23B7F84909764BA62F3C6F18CFE67DBF7DE0C321D698A7C69BC493F168327A2E3D1A9DCCA6E76783D8C9DDFB607C349BF57DDFC2E9A89015FA9129140CB1608BA8995A62E41628362A07388CC85424C70ED08C0B8B18B87D17215C6C891396922AB755CAE59D2DEFE74A63F36EE492ADDBB6E245556C3C549A2C6C16402B852D336861C994C652682B75A85816AFE1A63250F0456640308C870BAA18D15C2CAC772DB1FF9468A6239BF9593C8BCF3EC6C3FE4F3FEFE3E379F3C9E9FBD138EE5F17B786152584A129CA842B4864F1B94A16ECCA41F74A56A6AC4C74E19E6BF8FA15D80AF179606BF3AE31003DAF867AC80495890DE27CFE3E7C03610211F8EDDF7CF8F117FC5EBBF5BDF862341F4C8771BFFDAB87E8FB13CF36221F42ACE03EFC756873155E6B07C6CC043877CC215567B2CA136C3D96CF023A712589DCA4243C4D992D5A7EEFB54ECFDF8D4783BA9BED5D8BCF50608010746BA0477B5BACBFDE984528270CCF952B294EA81B90DA4FF74177A3BDA6A07BA8BB97CE75B4872FE5E1DFDF82469A1DAFE5920BBFA0B0118EBF4DAE45917B3617F0551510A64D81ABF76371BC56CABD7F29319A49F0474853BD7ACA6D031C1BD4730E417B0BF4C0F24CD00CC72510F85EAB58629C5B4DFF69D44E0DB5FEB3D3DFD16FF6BAF5DD4EC3AB57F02C4F4CD37B9626426E2CE5AD9BBCBA838EB82D0758040436E100D24A50CB1B3DCF05717234897198DBBB2947368CBA7B109AFB92410AA1620BB682E053B47719397BED002E3D683C5FC1A1066DDB36D73ADD6EB0967CBA8C2EBBDB57FC1D751741C7F706D3C929063C1B9C8D4EE7C3D199758FB3E538D96FEFFB9D26CFB4771D72435AE2D9F39B3E0C1DBF4F6C2FFDEBF22EB9F6A1BD4DACF36490FE6F6DB1900392D3CAEE929ABF907B178A380ACA7981CA58D30D614268192A82E38F932714D57BA4D4E3A38F4798C76EE34683733A1DEBF00FC5D1195B315A190B9A7A81F4F0247632DC4BAE0EEBAD9AB0275BCF2D9654E648A0F672BD43345E0E2F8A55EF914135FFC21A5C8D5B4FD27A899452E69E1D35CB427639F8F0F66D3C7DEFED3CFE79D8810FEBC59CD46B39DCAEE53AEEEFAC63B919B1C82659370B36BDB6FB976644209D5B6A453B786B69F7D67A494BFB7FA3422DA6945448D535155EB61FF65F76F7BEF9F0A26FDFF61B7C4193C6B99B121B1BAC3194736B3DBCD0FA4DE16AD37E6836E9DB2D84C3E9C97874125F1D9F0F3FC4FD03140CA793CD4BCD130E5F8167CBE3D1AC9009901F569BBA598708907DEF1F504B03040A0000000000B6B20B47B60BCA09210000002100000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A0A6A61766163204465746563744D61696E2E6A6176610A504B0304140000000800B6B20B4740C9FA99940300003D0800000F001C004465746563744D61696E2E6A6176615554090003A79FCA55C39FCA5575780B000104E803000004E80300009555DF6FDB380C7E4EFE0A5E1E16A72D94EB1ED3AC87439B151D9A2C68DA3B0C451F7436ED68674B3949EE2D18F2BF1F29D9F9D105C52E0F892352E4F7911FE9E149174EE01A3DA61E3EC9170995541AF25AA75E197A3016FC12A1502FA8A154CE83C9212DA573E804DFFDA82C1D4A5BD4156A0FCA057F87D2A64BC894A5C0C6AED995BDE7D28608EC73FD79FAB5CE0A84B935859555A5740157467BA4809F6ABB86C5DA79AC40EA8C52A7A853CC3848AD338CB06E668F7033BF13B04084FBC9EFD7D349F0BEFA3CFF723BBB09F033F4529501ECB0DB55D5CA1084AF4455945217C2625E124671727160D3188EBAABFA2F4A1D1937759A7285BE773B8DC979E9E9E7C5A82C162F8185B7C4E5E999CBE260C0CE9DE110AE9698FEBD2D95A3439593373B891275E1973086F78D7F27921768AD5851385FEAA4F7E86481A380701FCC98EA7C09E300F2FC127A7C1D7EFC9C42EFA9F17A7F09420878EE0D2EF6737D533E398F47167D6D353F6EBA11FE9D9159DB7AC8ADA9C0AD30553991DFF6993C1FEFEFF83FDFF4D4C3C085FEC307D0F82F9035E9E5AAC4D170D823444CFEE9D767C6368C6036904A4FDA49602A4B6A6085195D9A7C4B711524896F156862ADB123EA437373870CFAAFD2F57F8E7BA773C594993C892E2D773CF6CE93F68C7AFE9D73C2062854ACDB8D21AD5A53174B9065D956906C512660D1D5A5E7B875597252566D028AA7894ECF2FE867BCAF123A383D6D8B106390955C033BF51C1273E65B4DE2D45E498F312D9F07D8E3DF2E210D5CB73DEAA4142118050198C90A138A7706B92C1D9ED1FD589B5D7B82EFCCF88F8606F2487FDE6A509CA7B625A11DA08DA781A558A2E9CCB1D6ECF5260A93793E10076F2057BA19C10AFDD2646C9D86A7701A1F5F91DE19887D2A0AF4D748E02C66F134E9B147EF2CD69FCC817532785D8C9959D4E932DE39560B42B920D55311D6A00A6D2C959409E30B1296588EA574AFE17752DA874AD77848386E12DA1ECAF71D29254392FA8FFB88BDC38A999A8CE614AD506E11CCC98E37936AED4CAC591EEFDEEDDF9A87D83F75EBD0E73EB4EB61BDC26420F09F9AC494FC41D0C4C397F964B02D4F40D90CC22F7112B6B6A33AFA535A4DC21F45C5D0D237F43EB0D0E7EC7DAA08692B5E3EBA075BCDB542DB846F24A1BF95F356E76604B5E3816B1285357820E33664673BD664D9CBB2D9DBA833D3BC6E9943F7B00A1F0EABF0C62C69B345136A4101A56E35C5AB56FC9F2D4F324E316C8AC6DDD47E9B3262E3AB9BEEA6FB1F504B01021E03140000000800B6B20B47CD775514EB04000077090000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47B60BCA092100000021000000050018000000000001000000ED81280500006275696C645554050003A79FCA5575780B000104E803000004E8030000504B01021E03140000000800B6B20B4740C9FA99940300003D0800000F0018000000000001000000A481880500004465746563744D61696E2E6A6176615554050003A79FCA5575780B000104E803000004E8030000504B05060000000003000300E9000000650900000000, md5sum = '04327980d979b660f5575101554b7359' WHERE execid = 'java_javac_detect';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47B7C75068B0020000DD04000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D54EF6FDA3010FDDCFC1547E846BBB550F691B59526C83AA642A402DA87FDA88C73215E133BB29D4235ED7FDFD9495AA8F62521E7BB77F7DE3BD3ED0CD6420E4C16045D98AB04FBBF0D7055942247D86A5696A8CF0DD7A2B4902A0DBDE6AC6FB25E9F4A1688603366612FC73C49CB76C0640285D20842A68A72297B9909D366260A0D486581715BB13C7F82B0C10E0911C1A84A733C837565691061299B1184C930CF5B0CDF792B289056925BA12430E3AB7187BCB26C9DE308B6194AE0D40293331096407C499D827BCD286E33FFCD95D6C82D8D6E51971AE9D9D03AA3F3CA1006E1A9AD901BFA26522F89490B6615AC112A4311AB993425A3A7259E34A2489B41D8B3DA892B60602CE9C6722511C818A69F6AE5E6F1723A8E4675B3A642B73270269D906DB76716AB45743FFE7217C74B42E04AA6625369E66552A57FD94A4BAA50B203272B99A331506A459ED30B5F55A404E2B5C9B4A26E281F8556B2406921231A6B24952D7BF05A93EB2AED9F06C1245A2CAFC2E361081FC93A91DA6016CD6EA7B3E9EBE8A7E97C11AFEEC6918FBB6D1C67C81FEAA5EB767A0756E44292AF89923D5BFB406A3AF9E8F8D1CD639115CEA354AB024A668CF3A9A66C5C9EA3B187D70FC88F8DC6127ABF5CABF0F8659C10AE07093E0E64452BF3E1FAED9046A672191C21CF148491D64A8F0E17C5328B4E9713734AF357321985C191C73F97FF6B41583B22300C52E1887F73DBDEACA71BBC767914705AF66BAA749A86707919C59F83EEF3FDEDC20D4A24B3DC06BA4BD25E5BE2DBAEBABBE007A392AFF5B6F65DE309C568E913A1252BD05F609E31B94117DAD797E7A4A9BFBC9E1EA013C17819BF43F8E3F8CFC59BC1BBBF2174AEDCD745083F5BD178B277EEF9E2AE54DA423CBF9DCEA3FBAFABC94D743584493C6B7EBA0CE4D42C41FA6B3AD4CD2910F0AC5009B0F7BB561A5741725E04FF00504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B47B7C75068B0020000DD040000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81ED0200006275696C645554050003A79FCA5575780B000104E803000004E8030000504B05060000000002000200940000004B0300000000, md5sum = 'be0fdfb79aa34140d52ca1288997f4dd' WHERE execid = 'js';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B4791C4F2B5BE0200001E05000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D54614FDB3010FD9E5F71A48CC2062DEC63074C53C9B64A40255AB4491B9B5CE7422C523BB21D0A9AF6DFF7EC3450D0F22189EDBB7777EFDDB9B7355C283D746592F4E8BC1124CDB25615D3CA8ABA667BE0A455B5A7C258EAAFCF06AEEC0F603E63265F0A4F1B36EE517BF14042E7B4349649E9C2C016D6F352B9CE3237EC481B4F42FA4654D523A56BEC14884CCE3456F23E2D1A8F449487B500842BB9AA3A8C1879A5B051345A7A65340917BDF98165E3C5A2E211AD4AD6241182F37D521E20D1A535E18D60D8F7655C4B632D4B8FD43DDBDA32DEEBB2F671DE386000CFAC94BEC51A453D1BE61D9837B4606A1C76BC15DAD5026F8F3A91A22AD689E07F5D751E1C04390FDE446534134411F6B165EE723A9F8CB3511B6CED613B1AA4D081C82EDA5315D7B3ECF7F8EBD5743A078234BA50B78D15912653C78F6FAC8687D15BB47BAD2B768E6A6BA0393EFCCAA30048E4A6B406D158DF2B6BF492B5A712652C182C7B7117B986EAA618EC25C959369B9FA4DB47297D8074AAF0C94576713EB998BCDEFD34B99C4DAFAFC659DC0F9D382E59DEB54DD7DBEABF90A2521ABAE646F77DAB03D80CF4E1F83EE4E3592C834685354BAA857341A7B66417EC42191B7883047ADC5AAEA9FF2B844AB79FD349E97498F3FD50376899F7A73B474819EE3A213C2C4B436966ADB1A397BDE285E740CDAEDB43098DCE4769F488510EF4FF02B5880FA8E42829D433031526B2EDBD51827F4907F52BC7ECFB643E9E9E6527DB1F931F38EBD62922311DD20DEDECB4C84F4701FE5B98AAF5180482DA6E1A251243750A98A05D4AC7C7D9F473D27BBA237AF48535A32942A78761ECAE07F0DA8D544879930EB44F3B148310F70C7B98AD5C592D961CEF09590A7DCB616B53465941BA7847440A8903D12EAA85327F6EFF397C337CFB37A5AD93B03A4CE966431B996F984442437631B557ECA1BC44964B939378F7D0D51DCC41D861F20F504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B4791C4F2B5BE0200001E050000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81FB0200006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000590300000000, md5sum = '526b8b92242b421fcaba64447ca4492c' WHERE execid = 'lua';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B479119B9C0600100000E02000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300005D91CD4EC3301084CFCD532C69A4824452E8B15585108D5051D320421137E4389BC4E0D896EDFEC0D363A745206E5E7BBF9DD9F1F06C5C3231366D100CE1D1104A3850D929C611F69A28853A36543365A1961A46A7B7C4B4A3C4110522D89658F8D3633E85250720A2824E6A04266A9904C1222D9EE761741DC20C4CCB6A1B6469B65A66CBFFB7B7CB75916F9EEED2FEDEFB8A776C2FA68317D4A534CE17D18289C65C8290164DAFE44574472C93C26DD0A131A441E3D9ABC9743058E10E394C402ACB3AF6D5F71938AFB0265B7EB2AD10AB0B4F148D238AAD52525BE0A474A49768A4953E9BCE158EF58C6D7B3FAD04E160601666713FE2B5F023ACD3A1C099F8803DB32D10CE5D556AA299F3562B7ADC0CE27CE2553D067195AF57CB75FAF6B059DCA7AE5CE4D9E928C3C887184218FD861406786096CA0AE7D18D0F8B722402A846629D2559BE23750BBA3F33D3407710D7701C934897AD6721FA99107C03504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B479119B9C0600100000E020000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED819D0100006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000FB0100000000, md5sum = '8aa9acacbc3dae75764d74ec22d91cab' WHERE execid = 'pas';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B470E71FF23D80200003A05000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D546D6FDA3010FEBCFC8A23B0D26EE56D1F59E93441D63115980AA893B6AE32CE85580D76643B856ADA7FDFD9212D45FB92C4E7BBE7EE9EE72EF55A672564C7A4415087EFA833E06A938B0C61AB599EA36E19AE456E21511A9AFBBBB6499B6DF29F23824D9985031FF3242DDB0193316C9446103251E44BDE8B5498CA335668402A0B8CDB8265D913847BEC9010118C2A34C7735815960A1196BC19419814B3ACC2F099B7820C4921B9154A02333E1A77C80BCB5619F6619BA2044E29303E076109C487942E78908CEC36F567AEB4466EA9748B3AD748CF7D5BE7745F18C2203CB515724D676AEAC531AEC0AC82154261C86235932667F4B4D4279528927D21F4BDEF3A76010C8C25DE58A62402A9C2F453C9DC74B6180FA37E996C1FA12B1A38938EC82ADB7317CB79743FFC7A339B2D08812B998875A199A749E5FE650B2D2942C91A9C2E6586C640AE15694E2F3C8A4808C473936A45D9503E0AADE406A58594DA5821B16CD983E79A545749FB2C0846D17C31081BBD103E927422B1C1249A5C8F27E363EBE7F1743E5BDE0C236F77A3384C913F944357AF355F49910949BAC64A366DA903B1E9E8A3EB47578F45B6711A255A6D2067C6389DCA968DF3736D1CE0B503D263AD3187E66F972A6CBC9413C26527C6C78E2C68643E5C9EF4A8640A97C11BE4A98230D25AE9FEEB41B1CCA2E3E5D49C51FD858CFB61F0C6E3B7E4FF5210D68E1AE8058978693C779B58CE5C3FF0871687D6ED5164F463BC18CE46D1A0F129F84977D539A454085DB8839313F0E8CF572EC5AD5BA8FD06386ECA41EA079CF6E992609C6C215C5C44B32F41FDF9FF50872B9448F3E086DCED61F567204AAB6DF2951EB241A3532E44DB251E918DF62A165AB20DFA7F044F995CA3331D4A98B81F909B6A4F20A0A3D978A1A8CD5F8D3FDDB79D777F43A80DDCA91BC25D250B8F0FEE3DA3B8CB95B6309B5E8FA7D1FDB7E5E82A1AF460349BEC3F9D07F2B2F22376A9FD80A71B15037BBFAB7871FE446837F807504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B470E71FF23D80200003A050000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81150300006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000730300000000, md5sum = '64986eead7acea08925a77346e94f348' WHERE execid = 'pl';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B4700C4FAFDB7000000F600000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300005D8DBD6EC2301485773FC5694062C181CE28032A1922356D45CA5C99F4065B727C2DFB56D0B727A04AADBA1D7DE76FF6B03ABAB0CA56A919DE127B3EA1E7313A4F38271323259DFBE4A260E084C58F5766BB28A7464704B146F02793BF83980B4CF8C4C889E0C2C0A552BBBA7BAF8AF963810DB27583A8B66E9F9BB6F94FB7CD4BF77AD83FD577AE145DA8473EBBE8A1F5898DAF46E3C2D21A2F13C8321D7D18CF812A495F04CD28E6B7B302BA9FE4EFDE7DCB09D6EA0A504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B4700C4FAFDB7000000F6000000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81F40000006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000520100000000, md5sum = '71b2708a6647b68f6849d700b77ecfa5' WHERE execid = 'plg';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B4780D7421AE70200004B05000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D546D4FDB3010FE8C7FC591767463F48D8F8CB24D6D069D2899A0689336868C732516899DD90E6D35EDBFEFEC2650A67D89ECF3DD7377CF7397D66EFF4EAABECD186BC197B5CBB43A04A18B52E6084BC3CB124DD70A234B070B6DA053BFF56CD6E951C81522B88C3BD8F2B16BE5F80AB84AA1D00641AA85265FF29E67D2369EA9460B4A3BE0C2553CCFD710D5D8112122585D1981077057392A443AF2E6046133CCF30623645E4A322C2A259CD40AB80DD1B84251397E97E3112C3354202805A607201D8184908D0B6E2523BBCBC25D686350382ADDA1290DD2B76EEB80DE2B4B1884A79752DDD39D9A7A764C1B30A7E10EA1B26471862B5B72FA3AEA934A948BBA103AD75DA73E808375C41BCFB5422061B8596F98BB48E6D3715CF71232D661A6E1824C2157E8E1FA2ABE1D9F5D26C91CB4F225236188CC68E2DBE0AF4A1AA2B30C72D7754A45993D458C4DE2ABF9286A0F23784774CB8563B378763E9D4DFFB57E9C5E5C25D797E338D8FD048D33140F9B4169ED765ED0974B455AA45A75DC863B62C0E7A6E7475474445E785E17461750726B3DB7BAF4A25AEFE765D9C2EB31E2F0DE60099D9F3E55D47E2E2782937E8A8F7D5591CC87277B432A99C215DB419169886263B4397A29AEE30E0BAAE3B57D43F5572A3D8AD84EC0EFAAFFA520AC153530640BF9DCF86644584D6C97FA58DF36CB14B53F442CFE369D8F93493C6ABF67DFC9D4DC23CA8230801BD8DB8300FCF4C44C01DD0574BBB0DF2BD7C227FBEAD7A19E5FCFD266028E98A06D3821542F6004C7C771F289B59E16BC05A7A8D0F030A27E8B9ABD26729B5DA82BDF6686AE9B81EEF9D413B2D15EA4D2285E60D8719171758FDEB42DA7C849C2B0DF814D40CFB90DAA51E33FDABF07AFFAFB7F22D81DF9DB20829B4623916EBDD7F45A7484A5BA448D0D2D9F25B3181EB9917EC57DDE823F3C959FD16F6BCD70556AE320B9389F5EC4B79FAF27A7F168089364D61C3DC6A8EFFF437DAAB31FB019F35434402F15F7743291153A05FE76D5F0EC2348AF01FB0B504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B4780D7421AE70200004B050000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81240300006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000820300000000, md5sum = 'e320cd7a26fc57027022cdc681e4b0af' WHERE execid = 'py2';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47C42C3ED3E90200004E05000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D546D4FDB3010FE8C7FC591767463F485ED1BA36C539B41274A2628DAA48D21E35C89456267B603ADA6FDF79D9D04CAB42F917DBE7BEEEE79EED2D91EDE4835B419631DF8B27699566F41E8A29439C283E16589A66F8591A583A536D06BDE0636EB0D28E402115CC61D6CF8D8B5727C055CA550688320D552932F792F32695BCF54A305A51D70E12A9EE76B881AEC881011ACAE8CC03DB8A91C15221D797382B019E6798B11323F48322C2B259CD40AB80DD1B84251397E93E3013C64A840500A4CF7403A020921B50B6E2423BBCBC25D686350382ADDA1290DD2B7696B8FDE2B4B1884A71FA4BAA53B35F5E498B6604EC30D4265C9E20C57B6E4F475D4279528974D21746EBA4E7D0007EB88379E6B8540C270B3AE993B4B16B349DCF412323661A6E5824C2157E8E1F222BE9E9C9C27C902B4F225236188CC68E2DBE0AF4A1AA2B36CE4AE0B958A527B8E189BC6178B71D4DD8FE01DF12D978ECDE3F9E96C3EFBD7FA717676915C9E4FE260F72334C950DCD593D2D9EE3DE32F978AC448B5EAB99A3CA2C0E7A6E77B5474445E786297461750726B3DB9BAF4AA5AEFE775D9C01B3022F1D66009BD9F3E55D47D2A2782A3618AF7435591CE6F8E76F6A9640A576C0B45A6218A8DD1E6E0B9BA8E3B2CA88E97F615D55FA9F420625B01BFAFFE9782B056D4C03E5BCAA7C6EB19612DB37D6A647DDDAE53D4FD10B1F8DB6C3149A6F1B8FB9E7D27537B8F280DC208AE60670702F2E3133305F497D0EFC3EEA05C0B9FEDAB5F8866823D4DF50C1C3041FB7044A85EC1080E0FE3E413EB3CAE78078E51A1E16148FD1EB59B4DECB6DB5097FE8C1ABAD6233DF0A9A764A3CD48A551BCC0B0E522E3EA16BD69534F91938661C3039D809E741B64A3C67F747F8F5E0C77FF44B03DF6B7510457AD4822DD786FF8B5E8084BF5891A1B5A3E49E631DC7323FD92FBBC05BF7B2C3FA31FD79AE1AAD4C64172763A3B8BAF3F5F4E8FE3F13E4C93797BF418E3A1FF130DA9CE61C066CC53F1B81CCF35F77C3291153A05FE7AD512ED4348B011FB0B504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B47C42C3ED3E90200004E050000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81260300006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000840300000000, md5sum = '5054c0c43916ac3c40badd839629589e' WHERE execid = 'py3';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B471C2E543DF80200007105000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D54514FDB30107E26BFE29A76143668CB1E3B609ADA8C75A38D448B366963C8752E8D456A47B6435B4DFBEF3B3B0914B497243EDF7D77F77D7769B7FA4B21FB260B8236DC94CB1D70B52E448EB0D1AC28509F1AAE456121551ABAF55DCF64DD1EF9CF11C166CCC29E8FD949CBB6C064026BA511844C15F992F72213A6F14C141A90CA02E3B66479BE83B0C60E0911C1A852733C816569A91061C99B1184C930CF1B0C9F7923C89096925BA12430E3A3718BBCB46C99E31036194AE0940293131096407C48E5827BC9C86E337FE64A6BE4964AB7A80B8DF4ACDB3AA1FBD21006E1A98D902B3A5353CF8E490366152C114A4316AB993405A3A7A53EA94491D685D077DD75E20218184BBCB15C49045285E95DC5DC2C5E4C46D1B04A5647E88606CEA423B2C9F6D4C5ED3CBA1F7DB989E30521702553B12A35F334A9C2BF6CA9254528D982A35B99A3315068459AD30B5F45A404E2B9C9B4A26C281F8556728DD242466D2C9158B6ECC1734DAAABB4771C04E368BEB8083B67217C20E9446A836934BD9E4C27AFAD9F26B3797C7B338ABCDD8DE22843FE500D5DBBD57D21452E24E99A28D9B5950EC4A6A38FAE1F5D3D16D9DA69946AB5868219E374AA5A36CECFB5B187D70B488F95C602BABF5DAAB0F35C4E0897FD041FFBB2A491797F7978462553B80C0E90670AC2486BA5872F07C5328B8E9723734CF597321986C181C73F95FF4B41585B6AE02C48C573E3F5161D159AB00D84F3EA1C7F0BFD4AA422A75CAEAF8D2A7392706978A9B11E7E61B94AF0781868B7CFA7FC55BEE8C764318AC7D145E763F093EE9A734805220CE00E0E0F3D0A3C5DB9C2BEBB35ACF7C665AEC66F1870DAC24B82716287707E1EC59F83F6D35FA50D572891A6C8AD86DBDEE67F4242343BE8CBDCE79006AE5AA39E4B3C261B6D6322B4646BF47F169E31B94267DA179EE724B6FFAB78DE019D3AC6EB4B7DFEEAFC19BCE9BFFD1B42EBC29D0621DC356AF264EFDE0B81DB42690BF1EC7A328BEEBFDE8EAFA28B3318C7D3FAD37920AF4A7F452FF51FF06CAD1260EFB60D31CE9F181D04FF00504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B471C2E543DF802000071050000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81350300006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000930300000000, md5sum = 'b7b0c7fd3da4f2df908470038dd9af35' WHERE execid = 'rb';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B474768E07E24010000E001000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300004D904F4FC3300CC5EFF914A69BB40BEBE00A65424280B86C687FCE53D6B96DA4360E89A3EDE3E3D0882D52142BF93DFBBD4CEE16476317A1536A029B68E1ECB573E8E7A1F6C631D4BAEFF1048DA701668C816B1DF0E0A32D43372B45B34504EE34431634E461208F606C430208B20FBAC527983E40953A18BB84CA796A2972AEBC1E966539D2FF8CAC0FD323D464591B6B6C0BE9696EAC8B9C465F9B64F2DCA10C669210861102F5910D5910E65692A689E48D8641DB13A44D2E8101A8913008994AAD8E0829AD52BBF7EDEE6BF5524C1F8B6780D09986D5F766FDB9DEEFF2E57897FFF1B6CDB94BEE3C9E8CC79A5390BF0C8BABAF1571FEC662FA5A005E9CB80A697E40A7BD66BC879F2890D8F56D1CD07228155EB01E05951CA3C1029652676385FA05504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B474768E07E24010000E0010000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81610100006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000BF0100000000, md5sum = '4af83b3e691e76fc347f2aa57a25a2ae' WHERE execid = 'run';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B47E6C8E5F4C8010000DB02000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300005D525D6FD330147DF7AFB875C3CAD7D2F2CA56604A03445A1769E924249890EBDCCC16891DD9CE5684F8EF5C474B9996075BBEBEE79CEB73329F2DF7DA2CBD626C0E9514AD0069BB5EB7080F4EF43DBA532F9DEE0334D6C1E2F12EF56A914600220425023CE9F1BF4D100710A686CE3A046D1A4BBDD47D55EE8A2C7F4F08ED27153741A530C606D8230C1E6B78D0415123C24D95FFCCBE5E97E58E18A4358DBE1B9C08DA1AB0FDB885C1194258F31606D3A2F7D03B4B83D386CF000D714452A99C253134F7DA59D3A109A0842771243AF18B56296874DBCC18DBE4D56ECD93771CCEC02BDD04B6CDB797C5B6785EBD28AEAAF2E63ACBC73A633EBA2981279F38CBBF15BBACDCE4EBE423FB4EA5E9CCE1D420ACE0164E4E000F3AC0F18A8D8CD9E5455511E1CBBDF068448704FEAFC4211D555E919CA4183ED06D9C97C3F9795E7E66F363BA73F88206C90772CA2B6CDB29D6604917E51010462ACA2BA023EB68254FC1DBC1494CE3EFB1A19A0C506B370E1213964A983B8CA54844A8FBE8A56C05A510E36CEC405DE89C753E65BA017AFC8FE4CFEAC5F2F55F0EB3753CAD38DC9EC5580C03FA64FDA485359AB138DFE3708BE468CA82C51732A93A5B837873989E1EFBC9C715FB07504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B47E6C8E5F4C8010000DB020000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81050200006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000630200000000, md5sum = 'c9d6e84d7b9f703d93b95163702fa729' WHERE execid = 'scala';
UPDATE executable SET zipfile = 0x504B0304140000000800B6B20B4705D56A4A86020000A204000003001C0072756E5554090003A79FCA55C39FCA5575780B000104E803000004E80300006D53DB4E1B31107DC65F316C52D20BE4D2C794505564415B912C2241456A69E5786759AB1B7B657B4950D57FEF782F24A0BE58F65CCECC3933EE1C0E56520D6CC65807AEE345740736C33C07A1D785CC11368617059A132B8C2C1CA4DA40AFF1F56DD6EB53DA02115CC61DECC5D827E5F816B84A60AD0D8254A9A6588A5E66D2B69189460B4A3BE0C2953CCF9F2068B0034244B0BA34028F61553A6A443A8AE6045177D860549537920C69A984935A01B755366E51948EAF721CC3264305824A60720CD21148955287E05E31B2BBAC7A0B6D0C0A47AD3B3485413A1B5AC7E42F2D61109EDE48F5406F22B50B4C5A30A76185505AB238C3952D389D8E78528B326D1AA17BC33AF1091CAC23DD78AE15020D879BA73E63D370B19C04DD51009F88BF4C1D9B85B3AB6816BDB67E89E68BF8F6E63CACEC8CDDDCCEE3EB6514CF179320F0533ECF50FCAE07D939ECBDA0974B455A255AF55CCD8D3AF42D91FB11155D91AF3DEFD4E83514DC5ACF5D175E74EBE3BC6C7B787D461C1F0C16D0FBE94B05DD5D77019C0D127C1CA892C6F0F1EC68440C285DB1031499862034469BF14BF11D77B8A63EDEDA77D47FA99271C00E2AFC13F5BF1284B525022396CA1DF17A84636633E8EEB4F1082F73C3BB68791E4FC349F733FB4EBEF61D5028C210EEE1E8082AFC67972FF2CDAF69B3575E9D7A4BC74CD0969E118C9F6300A7A7617CC13ACF9FAF0397A8D0F06A75FC76B7FF8D446D77B4DEFA7D4168D5EB3DEBFBCA53B2D1BA26D228BEC6EAEB898CAB07F4A6FD29A6FE5FFB5F576908E895B6D5AC88E78FEE9FE19BC1FBBF011C4EFC6B18C07D3B1991ECF92B51715B68E3209E5F45F3F0D7D7DBE9653819C1349E35571F81025E69FD4A685282896CAD13E01FB6AD443E93B41DB27F504B03040A0000000000B6B20B47D08595FC1F0000001F00000005001C006275696C645554090003A79FCA55C39FCA5575780B000104E803000004E803000023212F62696E2F73680A23206E6F7468696E6720746F20636F6D70696C650A504B01021E03140000000800B6B20B4705D56A4A86020000A2040000030018000000000001000000ED810000000072756E5554050003A79FCA5575780B000104E803000004E8030000504B01021E030A0000000000B6B20B47D08595FC1F0000001F000000050018000000000001000000ED81C30200006275696C645554050003A79FCA5575780B000104E803000004E8030000504B0506000000000200020094000000210300000000, md5sum = '2b8fce532e685d33965e791d3524e0f9' WHERE execid = 'sh';
