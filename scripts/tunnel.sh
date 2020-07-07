#!/bin/bash

help() {
    echo "create an ngrok tunnel for verification"
    echo
    echo "syntax: tunnel [start|stop|help]"
    echo
    echo "commands:"
    echo "  start    starts the tunnel and prints the URL to use - WARNING: this will restart your container"
    echo "  stop     clears the tunnel and goes back to normal dev mode"
    echo "  reset    resets if tunnel wasn't closed properly previously"
    echo "  help     is this really necessary"
    echo
}

start() {
    # check if tunnel already open
    #  print warning message and return

    # start backend tunnel
    cd paramedics-web
    # TODO: for testing only
    docker-compose -f "docker-compose-dev.yaml" exec paramedics-api sh -c 'kill -9 "$(pgrep ngrok)"'

    docker-compose -f "docker-compose-dev.yaml" exec -T paramedics-api ngrok http 4000 --log=stdout > ngrok.log &
    sleep 0.5
    # get URL
    BACKEND_URL=$(docker-compose -f "docker-compose-dev.yaml" exec -T paramedics-api curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"(https:..[^"]*).*/\1/p')
    echo "BACKEND_URL: ${BACKEND_URL}"

    # set front end env var as backend url
    cd ../paramedics-react
    # restart container with env var
    docker-compose -f "docker-compose-dev.yaml" stop
    if [ -a "paramedics-react.env" ]; then
        if [ -z $(egrep REACT_APP_BACKEND_TUNNEL paramedics-react.env) ]; then
            echo "file exists, just add"
            echo "REACT_APP_BACKEND_TUNNEL=${BACKEND_URL}" >> paramedics-react.env
        else
            echo "file exists, edit needed"
            sed -i.bak "s|REACT_APP_BACKEND_TUNNEL=.*|REACT_APP_BACKEND_TUNNEL=${BACKEND_URL}|g" paramedics-react.env
            rm paramedics-react.env.bak
        fi
    else 
        echo "no file"
        echo "REACT_APP_BACKEND_TUNNEL=${BACKEND_URL}" > paramedics-react.env
    fi
    docker-compose -f "docker-compose-dev.yaml" up -d
    sleep 0.5
    docker-compose -f "docker-compose-dev.yaml" exec -T paramedics-react-dev ngrok http 3000 --log=stdout > ngrok.log &
    sleep 0.5
    # get URL
    FRONTEND_URL=$(docker-compose -f "docker-compose-dev.yaml" exec -T paramedics-react-dev curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"(https:..[^"]*).*/\1/p')
    echo "FRONTEND_URL: ${FRONTEND_URL}"



    # start frontend tunnel
    # echo url
}

stop() {
    cd paramedics-web
    docker-compose -f "docker-compose-dev.yaml" exec paramedics-api sh -c 'kill -9 "$(pgrep ngrok)"'
    echo "stop"
}

case "${1}" in
    "start" )
        start
        ;;
    "stop" )
        stop
        ;;
    "reset" )
        echo "reset";;
    "help" )
        help;;
    "" )
        help;;
    *)
        echo >&2 "Invalid command: ${1}"; echo; help; exit 1;;
esac