# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils git-2

DESCRIPTION="Raspberry Pi bootfiles"
HOMEPAGE="http://www.raspberrypi.org/"
EGIT_REPO_URI="git://github.com/raspberrypi/tools.git"

SLOT="0"

KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="${RDEPEND}
	>=dev-lang/python-2.5"

src_prepare() {
	epatch "${FILESDIR}/${PN}-mkimage-paths.patch"
}

src_install() {
	cd "${S}/mkimage"
	insinto /usr/share/raspberrypi-tools/mkimage
	doins args-uncompressed.txt boot-uncompressed.txt first32k.bin
	exeinto /usr/bin
	newexe imagetool-uncompressed.py raspberrypi-mkimage
}

pkg_postinst() {
	einfo "The mkimage tool has been installed as ${ROOT}/usr/bin/raspberrypi-mkimage"
}

