#!/bin/bash

CONTAINER_IMAGE=domjudge_web
CONTAINER_DB=domjudge_db
CONTAINER_WEB=domjudge_web

WEB_PORT=49155

echo ""
echo ""
echo ""
echo "make sure $CONTAINER_DB container is running"
echo "<<<<<<<<<<<<<<<<<Access to web interface http://localhost:$WEB_PORT >>>>>"
echo ""
echo ""
echo ""
sleep 1

docker run -ti --rm -p $WEB_PORT:80 --name $CONTAINER_WEB --link $CONTAINER_DB:$CONTAINER_DB \
    -v `pwd`/web/src/:/var/www/html \
    $CONTAINER_IMAGE
     

