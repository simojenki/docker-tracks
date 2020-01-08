#!/bin/bash

docker rmi --force simojenki/tracks:latest
docker build --pull -t simojenki/tracks:latest .
