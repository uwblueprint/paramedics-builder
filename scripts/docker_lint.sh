#!/bin/bash

# the shell command needs the name of the container so we can't rely on the docker-compose file
CURR_DIR=$(pwd | rev | cut -d'/' -f 1 | rev)

if [ "$CURR_DIR" = "paramedics-react" ]; then
    docker-compose -f "docker-compose-dev.yaml" exec -T paramedics-react-dev npm run lint
elif [ "$CURR_DIR" = "paramedics-web" ]; then
   docker-compose -f "docker-compose-dev.yaml" exec -T paramedics-api npm run lint
else
    # we never actually see this lol
    echo "Invalid directory - you need to be in /paramedics-web or /paramedics-react"
fi
