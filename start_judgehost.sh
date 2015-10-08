#!/bin/bash

CONTAINER_IMAGE=jerivas/domjudge_judgehost
CONTAINER_WEB=domjudge_web
CONTAINER_JUDGEHOST=domjudge_judgehost

echo ""
echo ""
echo ""
echo "make sure $CONTAINER_WEB container is running"
echo ""
echo ""
echo ""
sleep 1

docker run \
    --rm  \
    --name $CONTAINER_JUDGEHOST \
    --link $CONTAINER_WEB:$CONTAINER_WEB \
    --privileged \
    -v `pwd`/judgehost/Dockerfile/restapi.secret:/etc/domjudge/restapi.secret \
    $CONTAINER_IMAGE  $@

#    -ti \
#    --entrypoint /bin/bash \
#    --cap-add SYS_ADMIN \

     

