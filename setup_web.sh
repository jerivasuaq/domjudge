#!/bin/bash

IMAGE_NAME=domjudge_web

echo "building webing_web image..."

docker build -t $IMAGE_NAME web/Dockerfile

echo ""
echo ""
echo "docker image $IMAGE_NAME created."
echo ""


