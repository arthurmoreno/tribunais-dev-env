#!/bin/bash

########################
###    CONSTANTES    ###
########################

ROUTINES_PATH="$(dirname $(realpath $0))"
source $ROUTINES_PATH/constants.sh

######################
###    ROUTINES    ###
######################

source $ROUTINES_PATH/routines/deploy.sh
source $ROUTINES_PATH/routines/dev.sh
source $ROUTINES_PATH/routines/test.sh

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
