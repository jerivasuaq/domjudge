#!/bin/bash

CONTAINER_IMAGE=domjudge_test
CONTAINER_DB=domjudge_db
CONTAINER_WEB=domjudge_test

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

docker run -ti --rm -p $WEB_PORT:80 --link $CONTAINER_DB:$CONTAINER_DB \
    --privileged \
    $CONTAINER_IMAGE
     

