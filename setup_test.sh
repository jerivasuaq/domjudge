#!/bin/bash

IMAGE_NAME=domjudge_test

echo "building webing_web image..."

docker build -t $IMAGE_NAME test/Dockerfile

echo ""
echo ""
echo "docker image $IMAGE_NAME created."
echo ""


