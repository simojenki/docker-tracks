#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

[[ $(id -u -n) != "tracks" ]] &&
    echo "Must run as tracks user..." &&
    exit 1

export HOME=/data

cd /opt/tracks && bundle exec rails server -e production