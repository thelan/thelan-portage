# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

K_SECURITY_UNSUPPORTED="yes"
K_DEBLOB_AVAILABLE=0
ETYPE="sources"

inherit kernel-2 git-2
detect_version

DESCRIPTION="The very latest version of the Raspberry Pi patched Linux kernel"
HOMEPAGE="http://www.raspberrypi.org/ http://www.kernel.org"
EGIT_REPO_URI="git://github.com/raspberrypi/linux.git"
EGIT_BRANCH="rpi-3.6.y"
EGIT_COMMIT="d53095f614598a74e3c790486ecfe5fed5ea0036"

KEYWORDS="arm"
IUSE=""

RDEPEND="${RDEPEND}
	sys-boot/raspberrypi-bootfiles
	sys-kernel/raspberrypi-genkernel"

K_EXTRAEINFO="This kernel is not supported by Gentoo.  Please redirect all bugs to the Raspbery Pi Foundation at http://www.raspberrypi.org"

pkg_postinst() {
	postinst_sources
}
