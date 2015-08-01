#!/bin/bash


DB_PORT=49154

MYSQL_ROOT_PASSWORD=domjudge
MYSQL_USER=domjudge
MYSQL_PASSWORD=domjudge
MYSQL_DATABASE=domjudge

CONTAINER_NAME=domjudge_db

echo ""
echo ""
echo ""
echo ">>>>>>>to stop this contaier type >> docker stop $CONTAINER_NAME<< in another console<<<<<<<<<<<<<"
echo ""
echo ""
echo ""

sleep 1

docker run -ti --rm -p $DB_PORT:3306 --name $CONTAINER_NAME \
    -v `pwd`/db/data:/var/lib/mysql \
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" -e "MYSQL_USER=$MYSQL_USER" -e "MYSQL_PASSWORD=$MYSQL_PASSWORD" -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
    mysql

echo "done"


