#!/bin/bash

CONTAINER_IMAGE=domjudge_judgehost
CONTAINER_WEB=domjudge_web

echo ""
echo ""
echo ""
echo "make sure $CONTAINER_WEB container is running"
echo ""
echo ""
echo ""
sleep 1

docker run -ti --rm --link $CONTAINER_WEB:$CONTAINER_WEB \
    --cap-add SYS_ADMIN \
    -v `pwd`/judgehost/Dockerfile/restapi.secret:/etc/domjudge/restapi.secret \
    $CONTAINER_IMAGE 

#     --privileged \

     

