#!/bin/bash

source $ROUTINES_PATH/constants.sh
source $ROUTINES_PATH/routines/utils.sh

######################
###    ROUTINES    ###
######################

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
