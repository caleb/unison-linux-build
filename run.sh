#!/usr/bin/env bash

docker stop unison
docker rm unison

echo "Starting Unison Container"
docker run --name=unison --publish=5000:5000 --publish=1234:22 -d unison