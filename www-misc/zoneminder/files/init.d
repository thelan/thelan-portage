#!/sbin/runscript
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

start() {
        ebegin "Starting zoneminder"
        ${CMD_START}
        eend $?
}

stop() {
        ebegin "Stopping zoneminder"
        ${CMD_STOP}
        eend $?
}
