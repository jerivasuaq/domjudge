#!/bin/bash

DBUSER=domjudge
DBPASSWD=domjudge
DBPORT=49154
DBHOST=127.0.0.1
DBNAME=domjudge

mkdir -p db/data

# Extracted from domjudge-domserver_5.0.0-1_all.deb

mysql -u $DBUSER -p$DBPASSWD -P $DBPORT -h $DBHOST $DBNAME < db/mysql.sql
#mysql -u $DBUSER -p$DBPASSWD -P $DBPORT -h $DBHOST $DBNAME < db/mysql_db_structure.sql 
#mysql -u $DBUSER -p$DBPASSWD -P $DBPORT -h $DBHOST $DBNAME < db/mysql_db_defaultdata.sql
#mysql -u $DBUSER -p$DBPASSWD -P $DBPORT -h $DBHOST $DBNAME < db/mysql_db_files_defaultdata.sql
mysql -u $DBUSER -p$DBPASSWD -P $DBPORT -h $DBHOST $DBNAME < db/mysql_db_examples.sql
mysql -u $DBUSER -p$DBPASSWD -P $DBPORT -h $DBHOST $DBNAME < db/mysql_db_files_examples.sql

echo done!

