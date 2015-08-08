#!/bin/bash

IMAGE_NAME=domjudge_judgehost

echo "building $IMAGE_NAME image..."

docker build -t $IMAGE_NAME judgehost/Dockerfile

echo ""
echo ""
echo "docker image $IMAGE_NAME created."
echo ""


