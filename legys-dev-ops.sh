#!/bin/bash

########################
###    CONSTANTES    ###
########################

source ./constants.sh

######################
###    ROUTINES    ###
######################

source ./routines/deploy.sh
source ./routines/dev.sh
source ./routines/test.sh

clean-tribunais () {
    echo "Limpando sessões do tmux."
    tmux kill-session -t ${SCRAPY_SESSION}
    tmux kill-session -t ${SELENIUM_SESSION}
    tmux kill-session -t ${WEBSERVICE_SESSION}
    tmux kill-session -t ${WEBSHOOTER_SESSION}
}

clean-docker () {
    echo "Removendo docker containers."
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q) -f
}
