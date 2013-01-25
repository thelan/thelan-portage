# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit git-2

DESCRIPTION="Raspberry Pi bootfiles"
HOMEPAGE="http://www.raspberrypi.org/"

EGIT_REPO_URI="git://github.com/raspberrypi/firmware.git"
EGIT_PROJECT="rpi-firmware"
EGIT_BRANCH="next"

SLOT="0"

KEYWORDS="arm"
RESTRICT="strip test"

BOOTFILES="bootcode.bin fixup.dat fixup_cd.dat start.elf start_cd.elf"

src_install() {
	cd "${S}/boot"
	insinto /boot
	doins ${BOOTFILES}
}

pkg_postinst() {
	einfo "The Raspberry PI boot files are now installed in ${ROOT}/boot"
}
