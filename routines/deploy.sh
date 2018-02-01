#!/bin/bash

source $ROUTINES_PATH/constants.sh
source $ROUTINES_PATH/routines/utils.sh

######################
###    ROUTINES    ###
######################

deploy-prod() {
    tmux new -s ${WEBSHOOTER_SESSION} -d
    tmux send-keys -t ${WEBSHOOTER_SESSION} "cd ${WEBSHOOTER_DIR}" C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'eval $(docker-machine env aws-webshooter)' C-m

    tmux send-keys -t ${WEBSHOOTER_SESSION} 'export COMPOSE_FILE=docker-prod.yml' C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'docker rm -v $(docker ps -aq) -f' C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'docker-compose build && docker-compose up -d' C-m

    tmux send-keys -t ${WEBSHOOTER_SESSION} 'cd fetcher' C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'docker-compose build && docker-compose up -d' C-m

    tmux send-keys -t ${WEBSHOOTER_SESSION} "tmux kill-session -t ${WEBSHOOTER_SESSION}" C-m
    tmux attach -t ${WEBSHOOTER_SESSION}
}

deploy-homolog() {
    tmux new -s ${WEBSHOOTER_SESSION} -d
    tmux send-keys -t ${WEBSHOOTER_SESSION} "cd ${WEBSHOOTER_DIR}" C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'eval $(docker-machine env aws-webshooter-homolog)' C-m

    tmux send-keys -t ${WEBSHOOTER_SESSION} 'export COMPOSE_FILE=docker-test.yml' C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'docker rm -v $(docker ps -aq) -f' C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'docker-compose build && docker-compose up -d' C-m

    tmux send-keys -t ${WEBSHOOTER_SESSION} 'cd fetcher' C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'export COMPOSE_FILE=docker-compose.yml' C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'docker-compose build && docker-compose up -d' C-m

    tmux send-keys -t ${WEBSHOOTER_SESSION} "tmux kill-session -t ${WEBSHOOTER_SESSION}" C-m
    tmux attach -t ${WEBSHOOTER_SESSION}
}