#!/bin/bash

# Adds green text to echo output
function message {
    echo -e "\e[1m\e[32m$1"
    tput sgr0
}

# Brings up the containers
function startproject {
    docker-compose -f $WORKDIR/docker-compose.yml up -d --build
}

# Brings down the containers
function bringdown {
    docker rm -f motion
    docker rm -f nginx
    docker rm -f status_keeper
}

# Removes the container images
function removeimages {
    docker image rm motion-web_motion
    docker image rm motion-web_nginx
    docker image rm motion-web_statuskeeper
}

# Appends to the .env file
function addenv {
    echo $1 >> $ENVFILE
}

# Exits the script with an error
function reset {
    message "Error starting project"
    message "Delete your env file and try again"
    message "Aborting"
    exit 1
}

# Set the workdir of the script
WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Set the .env file location
ENVFILE=$WORKDIR/.env

# See if .env file already exists
# If it does, start the project without configuration
if test -f "$ENVFILE"; then
    message ".env file detected at $ENVFILE"
    message "Starting project with current variables"
    message "(If you wish to restart configuration, delete the .env file)"
    startproject || reset
    exit 0
fi

# Execute if no .env file found
message "No .env file detected"
message "Creating setup configuration"
echo ""

# Remove any containers that existed before
message "Bringing down pre-existing containers"
bringdown 2>/dev/null
# Remove any images that existed before
message "Deleting old images"
removeimages 2>/dev/null

# Read configuration variables
read -p "OS path for saved Motion files: " OSPATH
read -p "Motion web URL: " MOTION_URL
read -p "Motion API port: " API_PORT
read -p "Number of cameras: " CAMERA_NUMBER

# Create IP list variable based on number of cams
for i in $(seq 1 $CAMERA_NUMBER);
do
    read -p "Camera $i RTSP IP: " IP
    if [ $i = 1 ]; then
        IP_LIST="$IP"
    else
        IP_LIST="$IP_LIST,$IP"
    fi
done

# Add all configuration variables to the .env file
addenv "FOOTAGE_DIR=$OSPATH"
addenv "MOTION_URL=$MOTION_URL"
addenv "API_PORT=$API_PORT"
addenv "CAMERA_NUMBER=$CAMERA_NUMBER"
addenv "FIRST_CAM_PORT=8081"
addenv "LAST_CAM_PORT=808$CAMERA_NUMBER"
addenv "IP_LIST=\"$IP_LIST\""

# Start the project
message "All configuration complete"
message "Starting project"
startproject || reset
