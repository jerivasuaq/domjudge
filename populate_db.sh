#!/bin/bash

DBUSER=domjudge
DBPASSWD=domjudge
DB_HOST=127.0.0.1


MYSQL="mysql -u domjudge -pdomjudge -h 127.0.0.1 domjudge "
mysql -P 49154 domjudge < db/mysql_db_structure.sql 

echo done!

