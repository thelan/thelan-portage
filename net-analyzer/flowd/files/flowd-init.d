#!/sbin/runscript
# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

depend() {
	need net
	before iptables
}

checkconfig() {
	if [ ! -e /etc/flowd.conf ] ; then
		eerror "You need an /etc/flowd.conf file to run flowd"
		return 1
	fi
}

start() {
	checkconfig || return 1
	ebegin "Starting flowd"
	start-stop-daemon --start --pidfile /var/run/flowd.pid --exec /usr/sbin/flowd
	eend $?
}

stop() {
	ebegin "Stopping flowd"
	start-stop-daemon --stop --pidfile /var/run/flowd.pid
	eend $?
}
