#!/bin/bash

source ./constants.sh

######################
###    HELPERS     ###
######################

wait-webserver () {
    LOADING="loading webserver "
    declare -i i=0
    tput sc
    while [ ! "$(docker ps -q -f name=webserver)" ]
    do
        tput rc; tput el
        i=$(( (i+1) %4 ))
        printf "\r${LOADING} ${spin:$i:1}"
        sleep .1
    done
    tput rc; tput ed;
    echo "\rwebserver loaded successfully"
}

wait-webserver-logs () {
    LOADING="waiting for webserver logs: "
    declare -i TIME=$1
    declare -i count=0
    tput sc
    while [ $TIME != $count ]
    do
        tput rc; tput el
        printf "\r${LOADING} ${count} (${TIME})"
        count=$(( $count + 1 ))
        sleep 1
    done
        tput rc; tput el
    echo "\rshowing logs"
    tput rc; tput ed;
}
