# add some basic commands to .bashrc
# Author:zhangzju@github
# Updated:2017-04-05

sudo echo "alias docker-pid=\"sudo docker inspect --format '{{.State.Pid}}'\"
alias docker-ip=\"sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}'\"
alias docker-dpid=\"sudo echo $(pidof dockerd)\"
alias docker-status=\"sudo systemctl is-active docker\"
function docker-enter() {
    if [ -e $(dirname '$0')/nsenter ]; then
        NSENTER=$(dirname \"$0\")/nsenter
    else
        NSENTER=$(which nsenter)
    fi
    [ -z \"$NSENTER\" ] && echo \"WARN Cannot find nsenter\" && return
    if [ -z \"$1\" ]; then
        echo \"Usage: `basename \"$0\"` CONTAINER [COMMAND [ARG]...]\"
        echo \"\"
        echo \"Enters the Docker CONTAINER and executes the specified COMMAND.\"
        echo \"If COMMAND is not specified, runs an interactive shell in CONTAINER.\"
    else
        PID=$(sudo docker inspect --format \"{{.State.Pid}}\" \"$1\")
        if [ -z \"$PID\" ]; then
            echo \"WARN Cannot find the given container\"
            return
        fi
        shift
        OPTS=\"--target $PID --mount --uts --ipc --net --pid\"
        if [ -z \"$1\" ]; then
            sudo $NSENTER --target $PID --mount --uts --ipc --net --pid su - root
        else
            sudo $NSENTER --target $PID --mount --uts --ipc --net --pid env -i $@
        fi
    fi
}
function docker-update(){
	if [ -e $1];then
		sudo apt-get update
		sudo apt-get upgrade -y
	elif [ \"$1\"=\"f\" ];then
		sudo apt-get install apt-transport-https -y
		sudo apt-get install -y lxc-docker
	else 
		sudo apt-get update -y lxc-docker 
	fi
}
alias docker-kill='docker kill $(docker ps -a -q)'
alias docker-cleanc='docker rm $(docker ps -a -q)'
alias docker-cleani='docker rmi $(docker images -q -f dangling=true)'
alias docker-clean='dockercleanc || true && dockercleani'" >> /root/.bashrc