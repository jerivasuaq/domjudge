#!/bin/bash

IMAGE_NAME=jerivas/domjudge_judgehost

echo "building $IMAGE_NAME image..."

docker build -t $IMAGE_NAME judgehost/Dockerfile

echo ""
echo ""
echo "docker image $IMAGE_NAME created."
echo ""


