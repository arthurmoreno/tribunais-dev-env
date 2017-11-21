#!/bin/bash

SCRAPY_SESSION="scrapy"
SCRAPY_DIR="/home/arthur/Projetos/tribunais/tribunais_scrapy"

SELENIUM_SESSION="selenium"
SELENIUM_DIR="/home/arthur/Projetos/tribunais/tribunais_selenium"

WEBSERVICE_SESSION="webservice"
WEBSERVICE_DIR="/home/arthur/Projetos/tribunais/tribunais_ws"

WEBSHOOTER_SESSION="webshooter"
WEBSHOOTER_DIR="/home/arthur/Projetos/webshooter"

ROBOMONGO_DIR="/home/arthur/robo3t-1.1.1-linux-x86_64-c93c6b0/bin"
ROBOMONGO_EXEC="robo3t"

spin='-\|/'

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

selenium-test() {
    clean-docker
    clean-tribunais

    tmux new -s ${SELENIUM_SESSION} -d
    tmux send-keys -t ${SELENIUM_SESSION} "cd ${SELENIUM_DIR}" C-m
    tmux send-keys -t ${SELENIUM_SESSION} 'docker-compose -f docker-test.yml build' C-m
    tmux send-keys -t ${SELENIUM_SESSION} 'docker-compose -f docker-test.yml up' C-m

    tmux split-window -p 25 -v -t ${SELENIUM_SESSION}
    tmux select-pane -t 0
    tmux split-window -p 75 -h -t ${SELENIUM_SESSION}
    tmux select-pane -t 2

    wait-webserver

    tmux send-keys -t ${SELENIUM_SESSION}.2 "pyenv activate tribunais" C-m
    tmux send-keys -t ${SELENIUM_SESSION}.2 "ipython" C-m

    wait-webserver-logs 10

    tmux send-keys -t ${WEBSERVICE_SESSION}.2 "import requests" C-m
    tmux send-keys -t ${SELENIUM_SESSION}.1 "docker logs tribunais-selenium-webserver -f --tail=99" C-m
    tmux attach -t ${SELENIUM_SESSION}.2
}

webservice-test() {
    clean-docker
    clean-tribunais

    tmux new -s ${WEBSERVICE_SESSION} -d
    tmux send-keys -t ${WEBSERVICE_SESSION} "cd ${WEBSERVICE_DIR}" C-m
    tmux send-keys -t ${WEBSERVICE_SESSION} 'docker-compose -f docker-test.yml build' C-m
    tmux send-keys -t ${WEBSERVICE_SESSION} 'docker-compose -f docker-test.yml up' C-m

    tmux split-window -p 25 -v -t ${WEBSERVICE_SESSION}
    tmux select-pane -t 0
    tmux split-window -p 75 -h -t ${WEBSERVICE_SESSION}
    tmux select-pane -t 2

    wait-webserver

    tmux send-keys -t ${WEBSERVICE_SESSION}.2 "pyenv activate tribunais" C-m
    tmux send-keys -t ${WEBSERVICE_SESSION}.2 "ipython" C-m

    wait-webserver-logs 10

    tmux send-keys -t ${WEBSERVICE_SESSION}.1 "cd ${ROBOMONGO_DIR}" C-m
    tmux send-keys -t ${WEBSERVICE_SESSION}.1 "./${ROBOMONGO_EXEC} &" C-m
    tmux send-keys -t ${WEBSERVICE_SESSION}.1 "docker logs tribunais-ws-worker -f --tail=99" C-m

    tmux send-keys -t ${WEBSERVICE_SESSION}.2 "import requests" C-m
    tmux attach -t ${WEBSERVICE_SESSION}.2
}

webshooter-test() {
    clean-docker
    clean-tribunais

    tmux new -s ${WEBSHOOTER_SESSION} -d
    tmux send-keys -t ${WEBSHOOTER_SESSION} "cd ${WEBSHOOTER_DIR}" C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'docker-compose -f docker-test.yml build' C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION} 'docker-compose -f docker-test.yml up' C-m

    tmux split-window -p 25 -v -t ${WEBSHOOTER_SESSION}
    tmux select-pane -t 0
    tmux split-window -p 75 -h -t ${WEBSHOOTER_SESSION}
    tmux select-pane -t 2

    wait-webserver

    tmux send-keys -t ${WEBSHOOTER_SESSION}.2 "cd ${WEBSHOOTER_DIR}" C-m
    tmux send-keys -t ${WEBSHOOTER_SESSION}.2 "docker-compose exec webserver /bin/bash" C-m

    wait-webserver-logs 20

    tmux send-keys -t ${WEBSHOOTER_SESSION}.1 "docker logs crops_worker -f --tail=99" C-m
    tmux attach -t ${WEBSHOOTER_SESSION}.2
}

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
