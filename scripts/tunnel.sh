#!/bin/bash

help() {
    echo "create an ngrok tunnel for verification"
    echo " note: both start/stop will restart your container"
    echo
    echo "syntax: tunnel [start|stop|help]"
    echo
    echo "commands:"
    echo "  start    starts the tunnel and prints the URL to use"
    echo "  stop     clears the tunnel and goes back to normal dev mode"
    echo "  help     is this really necessary"
    echo
}

start() {
    echo "🚑 opening backend tunnel..."
    cd paramedics-web
    docker-compose -f "docker-compose-dev.yaml" exec -T paramedics-api ngrok http 4000 --log=stdout > ngrok.log &
    sleep 0.5
    # get URL from ngrok status
    BACKEND_URL=$(docker-compose -f "docker-compose-dev.yaml" exec -T paramedics-api curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"(https:..[^"]*).*/\1/p')
    echo "🚑 backend URL (for reference):"
    echo $BACKEND_URL

    echo ""
    echo "🚑 linking backend tunnel to frontend..."
    cd ../paramedics-react
    docker-compose -f "docker-compose-dev.yaml" stop

    # add backend url as environment variable
    if [ -a "paramedics-react.env" ]; then
        if [ -z $(egrep REACT_APP_BACKEND_TUNNEL paramedics-react.env) ]; then
            # env file already exists but var not set - append to env file
            echo "REACT_APP_BACKEND_TUNNEL=${BACKEND_URL}" >> paramedics-react.env
        else
            # env file already exists and var already set - replace URL in env file
            sed -i.bak "s|REACT_APP_BACKEND_TUNNEL=.*|REACT_APP_BACKEND_TUNNEL=${BACKEND_URL}|g" paramedics-react.env
            rm paramedics-react.env.bak
        fi
    else 
        # env file does not exist - put URL in new env file
        echo "REACT_APP_BACKEND_TUNNEL=${BACKEND_URL}" > paramedics-react.env
    fi

    # restart container to pick up new env var
    docker-compose -f "docker-compose-dev.yaml" up -d
    sleep 0.5

    echo ""
    echo "🚑 opening frontend tunnel..."
    docker-compose -f "docker-compose-dev.yaml" exec -T paramedics-react-dev ngrok http 3000 --log=stdout > ngrok.log &
    sleep 0.5
    # get URL from ngrok status
    FRONTEND_URL=$(docker-compose -f "docker-compose-dev.yaml" exec -T paramedics-react-dev curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"(https:..[^"]*).*/\1/p')

    echo ${FRONTEND_URL} | pbcopy

    echo ""
    echo "🚑 tunneling complete - ***don't forget to run 'tunnel stop' to resume dev work***"
    echo "🚑 frontend URL (also added to your clipboard):"
    echo ${FRONTEND_URL}
}

stop() {
    echo "🚑 stopping backend tunnel..."
    cd paramedics-web
    docker-compose -f "docker-compose-dev.yaml" exec paramedics-api sh -c 'kill -9 "$(pgrep ngrok)"'
    sleep 0.5
    rm ngrok.log

    echo "🚑 unlinking backend tunnel to frontend..."
    cd ../paramedics-react
    docker-compose -f "docker-compose-dev.yaml" stop
    rm ngrok.log
    if [ -a "paramedics-react.env" ]; then
        sed -i.bak "/REACT_APP_BACKEND_TUNNEL=.*/d" paramedics-react.env
        rm paramedics-react.env.bak
    fi
    docker-compose -f "docker-compose-dev.yaml" up -d

    echo ""
    echo "🚑 tunnel stop complete - you can resume dev work now!"
}

case "${1}" in
    "start" )
        start
        ;;
    "stop" )
        stop
        ;;
    "help" )
        help
        ;;
    "" )
        help
        ;;
    *)
        echo >&2 "Invalid command: ${1}"; echo; help; exit 1;;
esac