# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

K_SECURITY_UNSUPPORTED="yes"
K_DEBLOB_AVAILABLE=0
ETYPE="sources"
CKV="${PVR/-r}"
CKV="${CKV/-git}"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"
inherit kernel-2
detect_version

DESCRIPTION="The very latest version of the Raspberry Pi patched Linux kernel"
HOMEPAGE="http://www.raspberrypi.org/ http://www.kernel.org"
KEYWORDS="arm"
IUSE=""

SRC_URI="${KERNEL_URI}"

RDEPEND="${RDEPEND}
	sys-boot/raspberrypi-bootfiles
	sys-kernel/raspberrypi-genkernel"

K_EXTRAEINFO="This kernel is not supported by Gentoo.  Please redirect all bugs to the Raspbery Pi Foundation at http://www.raspberrypi.org"

UNIPATCH_STRICTORDER=1
UNIPATCH_LIST="${FILESDIR}/linux-${OKV}/*.patch"

pkg_postinst() {
	postinst_sources
}
