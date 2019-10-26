#!/bin/bash

function message {
    echo -e "\e[1m\e[32m$1"
    tput sgr0
}

function startproject {
    docker-compose -f $WORKDIR/docker-compose.yml up -d --build
}

function bringdown {
    docker rm -f motion
    docker rm -f nginx
    docker rm -f status_keeper
}

function removeimages {
    docker image rm motion-web_motion
    docker image rm motion-web_nginx
    docker image rm motion-web_statuskeeper
}

function addenv {
    echo $1 >> $ENVFILE
}

function reset {
    message "Error starting project"
    message "Delete your env file and try again"
    message "Aborting"
    exit 1
}

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ENVFILE=$WORKDIR/.env

if test -f "$ENVFILE"; then
    message ".env file detected at $ENVFILE"
    message "Starting project with current variables"
    message "(If you wish to restart configuration, delete the .env file)"
    startproject || reset
    exit 0
fi

message "No .env file detected"
message "Creating setup configuration"
echo ""

message "Bringing down pre-existing containers"
bringdown 2>/dev/null
message "Deleting old images"
removeimages 2>/dev/null

read -p "OS path for saved Motion files: " OSPATH

read -p "Motion web URL: " MOTION_URL

read -p "Motion API port: " API_PORT

read -p "Number of cameras: " CAMERA_NUMBER

for i in $(seq 1 $CAMERA_NUMBER);
do
    read -p "Camera $i RTSP IP: " IP
    if [ $i = 1 ]; then
        IP_LIST="$IP"
    else
        IP_LIST="$IP_LIST,$IP"
    fi
done

addenv "FOOTAGE_DIR=$OSPATH"
addenv "MOTION_URL=$MOTION_URL"
addenv "API_PORT=$API_PORT"
addenv "CAMERA_NUMBER=$CAMERA_NUMBER"
addenv "FIRST_CAM_PORT=8081"
addenv "LAST_CAM_PORT=808$CAMERA_NUMBER"
addenv "IP_LIST=\"$IP_LIST\""

message "All configuration complete"
message "Starting project"

startproject || reset
