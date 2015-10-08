#!/bin/bash

CONTAINER_IMAGE=jerivas/domjudge_web
CONTAINER_DB=domjudge_db
CONTAINER_WEB=domjudge_web

WEB_PORT=49255

echo ""
echo ""
echo ""
echo "make sure $CONTAINER_DB container is running"
echo "<<<<<<<<<<<<<<<<<Access to web interface http://localhost:$WEB_PORT >>>>>"
echo ""
echo ""
echo ""
sleep 1

docker run \
    --rm \
    -p $WEB_PORT:80 \
    --name $CONTAINER_WEB \
    --link $CONTAINER_DB:$CONTAINER_DB \
    -v `pwd`/web/Dockerfile/domserver.dbconfig.php:/etc/domjudge/domserver.dbconfig.php \
    -v `pwd`/web/src/:/var/www/html \
    -v `pwd`/web/Dockerfile/30-domjudge.ini:/etc/php5/apache2/conf.d/30-domjudge.ini \
    $CONTAINER_IMAGE $@
     
#    -ti \

