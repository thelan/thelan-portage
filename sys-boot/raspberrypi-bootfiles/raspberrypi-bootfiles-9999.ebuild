# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit git-2

DESCRIPTION="Raspberry Pi bootfiles"
HOMEPAGE="http://www.raspberrypi.org/"

EGIT_REPO_URI="git://github.com/raspberrypi/firmware.git"
EGIT_PROJECT="rpi-firmware"
EGIT_COMMIT="e73e84c7229d20026b5c07fe625cc881c5475c8c"

SLOT="0"

KEYWORDS="arm"
IUSE="lowmem"

E_MACHINE=""
RESTRICT="strip test"

#BOOTFILES="arm128_start.elf arm192_start.elf arm224_start.elf arm240_start.elf \
BOOTFILES="arm128_start.elf arm192_start.elf arm224_start.elf \
	bootcode.bin loader.bin"

START_LOWMEM="128"
#START_HIGHMEM="240"
START_HIGHMEM="224"

src_install() {
	cd "${S}/boot"
	insinto /boot
	doins ${BOOTFILES}
	if [ use lowmem ] ; then
		newins "${S}/boot/arm${START_LOWMEM}_start.elf" start.elf
	else
		newins "${S}/boot/arm${START_HIGHMEM}_start.elf" start.elf
	fi
}

pkg_postinst() {
	einfo "The Raspberry PI boot files are now installed in ${ROOT}/boot"
}
