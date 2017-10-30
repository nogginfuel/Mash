#!/bin/bash
echo ' ___/\/\/\/\/\____________________________/\/\_____________________________'
echo ' _/\/\__________/\/\/\______/\/\/\/\____/\/\/\/\/\__/\/\__/\/\__/\/\__/\/\_'
echo ' _/\/\__/\/\/\______/\/\____/\/\__/\/\____/\/\______/\/\/\/\____/\/\__/\/\_'
echo ' _/\/\____/\/\__/\/\/\/\____/\/\__/\/\____/\/\______/\/\__________/\/\/\/\_'
echo ' ___/\/\/\/\/\__/\/\/\/\/\__/\/\__/\/\____/\/\/\____/\/\______________/\/\_'
echo '_______________________________________________________________/\/\/\/\___ '
echo -e '\n\nAutomatic installer\n'

if [[ "$UID" -ne "0" ]];then
	echo 'You must be root to install Gantry Container Manager !'
	exit
fi

### BEGIN PROGRAM

INSTALL_DIR='/srv/gantry'

if [[ -d "$INSTALL_DIR" ]];then
	echo "You already have Gantry Container Manager installed. You'll need to remove $INSTALL_DIR if you want to install"
	exit 1
fi

echo 'Installing requirement...'

apt-get update &> /dev/null

hash python &> /dev/null || {
	echo '+ Installing Python'
	apt-get install -y python > /dev/null
}

hash pip &> /dev/null || {
	echo '+ Installing Python pip'
	apt-get install -y python-pip > /dev/null
}

python -c 'import flask' &> /dev/null || {
	echo '| + Flask Python...'
	pip install flask==0.9 2> /dev/null
}


hash git &> /dev/null || {
	echo '+ Installing Git'
	apt-get install -y git > /dev/null
}

echo 'Cloning Gantry Container Manager...'
git clone https://github.com/nogginfuel/Mash.git "$INSTALL_DIR"

echo -e '\nInstallation complete!\n\n'


echo 'Adding /etc/init.d/gantry...'

cat > '/etc/init.d/gantry' <<EOF
#!/bin/bash
# All rights reserved.
#
# Author:
#
# /etc/init.d/gantry
#
### BEGIN INIT INFO
# Provides: gantry
# Required-Start: \$local_fs \$network
# Required-Stop: \$local_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: GANTRY Start script
### END INIT INFO


WORK_DIR="$INSTALL_DIR"
SCRIPT="gantry.py"
DAEMON="/usr/bin/python \$WORK_DIR/\$SCRIPT"
PIDFILE="/var/run/gantry.pid"
USER="root"

function start () {
	echo -n 'Starting server...'
	/sbin/start-stop-daemon --start --pidfile \$PIDFILE \\
		--user \$USER --group \$USER \\
		-b --make-pidfile \\
		--chuid \$USER \\
		--chdir \$WORK_DIR \\
		--exec \$DAEMON
	echo 'done.'
	}

function stop () {
	echo -n 'Stopping server...'
	/sbin/start-stop-daemon --stop --pidfile \$PIDFILE --signal KILL --verbose
	echo 'done.'
}


case "\$1" in
	'start')
		start
		;;
	'stop')
		stop
		;;
	'restart')
		stop
		start
		;;
	*)
		echo 'Usage: /etc/init.d/gantry {start|stop|restart}'
		exit 0
		;;
esac

exit 0
EOF

mkdir -p /etc/gantry/auto
chmod +x '/etc/init.d/gantry'
update-rc.d gantry defaults &> /dev/null
echo 'Done'
/etc/init.d/gantry start
echo 'Connect to your local on http://your-ip-address:5000/'
