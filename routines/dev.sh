#!/bin/bash

source ./constants.sh
source ./routines/utils.sh

######################
###    ROUTINES    ###
######################

scrapydev() {
    clean-docker
    clean-tribunais
    tmux new -s ${SCRAPY_SESSION} -d

    tmux send-keys -t ${SCRAPY_SESSION} "cd ${ROBOMONGO_DIR}" C-m
    tmux send-keys -t ${SCRAPY_SESSION} "./${ROBOMONGO_EXEC} &" C-m

    tmux send-keys -t ${SCRAPY_SESSION} "cd ${SCRAPY_DIR}" C-m
    if [ "$1" = "build" ]
    then
        tmux send-keys -t ${SCRAPY_SESSION} 'docker-compose build' C-m
    fi
    tmux send-keys -t ${SCRAPY_SESSION} 'docker-compose run tribunais' C-m

    tmux attach -t ${SCRAPY_SESSION}
}

selenium-dev() {
    clean-docker
    clean-tribunais
    tmux new -s ${SELENIUM_SESSION} -d
    tmux send-keys -t ${SELENIUM_SESSION} "cd ${SELENIUM_DIR}" C-m
    tmux send-keys -t ${SELENIUM_SESSION} 'docker-compose build' C-m
    tmux send-keys -t ${SELENIUM_SESSION} 'docker-compose up' C-m

    tmux split-window -p 25 -v -t ${SELENIUM_SESSION}
    tmux select-pane -t 0
    tmux split-window -p 75 -h -t ${SELENIUM_SESSION}
    tmux select-pane -t 2

    wait-webserver

    tmux send-keys -t ${SELENIUM_SESSION}.2 "cd ${SELENIUM_DIR}" C-m
    tmux send-keys -t ${SELENIUM_SESSION}.2 "docker-compose exec webserver /home/selenium/venv/bin/ipython" C-m

    wait-webserver-logs 10

    tmux send-keys -t ${WEBSERVICE_SESSION}.2 "import requests" C-m
    tmux send-keys -t ${SELENIUM_SESSION}.1 "docker logs tribunais-selenium-webserver -f --tail=99" C-m
    tmux attach -t ${SELENIUM_SESSION}.2
}