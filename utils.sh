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