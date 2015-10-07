#!/bin/bash


DB_PORT=49254

MYSQL_ROOT_PASSWORD=domjudge
MYSQL_USER=domjudge
MYSQL_PASSWORD=domjudge
MYSQL_DATABASE=domjudge

CONTAINER_NAME=domjudge_db

DB_STORE_PATH=`pwd`

echo ""
echo ""
echo ""
echo ">>>>>>>to stop this contaier type >> docker stop $CONTAINER_NAME<< in another console<<<<<<<<<<<<<"
echo ""
echo ""
echo "$DB_STORE_PATH"

sleep 1

mkdir -p db/data

docker run \
    --rm \
    -p $DB_PORT:3306 \
    --name $CONTAINER_NAME \
    -v $DB_STORE_PATH/db/data:/var/lib/mysql \
    -v $DB_STORE_PATH/db/30-domjudge.cnf:/etc/mysql/conf.d/30-domjudge.cnf \
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" -e "MYSQL_USER=$MYSQL_USER" -e "MYSQL_PASSWORD=$MYSQL_PASSWORD" -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
    mysql

echo "done"

# -ti 


