# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="Proprietary libraries for the Broadcom BCM2835 SoC (including the Raspberry Pi computer)"
HOMEPAGE="http://www.broadcom.com/ http://www.raspberrypi.org/"

inherit git-2

EGIT_REPO_URI="git://github.com/raspberrypi/firmware.git"
EGIT_PROJECT="rpi-firmware"
EGIT_COMMIT="e73e84c7229d20026b5c07fe625cc881c5475c8c"

SLOT="0"

KEYWORDS="arm"

# TODO: Make the samples actually optional
IUSE="X +samples"

DEPEND="X? ( || ( <media-libs/mesa-8.0[-egl,-gles,-openvg] >=media-libs/mesa-8.0[-egl,-gles1,-gles2,-openvg] ) )"
RDEPEND="${DEPEND}"
RESTRICT="mirror strip test"

# QA Silencing
QA_TEXTRELS="
	opt/vc/lib/libbcm_host.so
	opt/vc/lib/libGLESv2.so
	opt/vc/lib/libluammal.so
	opt/vc/lib/libmmal.so
	opt/vc/lib/libEGL.so
	opt/vc/lib/libopenmaxil.so
"

QA_EXECSTACK="
	opt/vc/bin/vchiq_test
	opt/vc/bin/vcdbg
	opt/vc/bin/vcmemmap
	opt/vc/bin/tvservice
	opt/vc/bin/edidparser
	opt/vc/bin/vcgencmd
	opt/vc/sbin/vcfiled
"

src_install() {
	cd "${S}/hardfp/opt/vc"
	insinto /opt/vc
	doins -r include lib
	use samples && doins -r src
	exeinto /opt/vc/bin
	doexe bin/*
	exeinto /opt/vc/sbin
	doexe sbin/*

	dodoc "LICENCE"

	# Create symlinks for header files
	local vcos_include_dir
	vcos_include_dir="/opt/vc/include/interface/vcos"
	local vcos_includes
	vcos_includes="vcos_futex_mutex.h"
	vcos_includes+=" vcos_platform.h"
	vcos_includes+=" vcos_platform_types.h"
	for vcos_include in ${vcos_includes}; do
		dosym "${vcos_include_dir}/pthreads/${vcos_include}" \
			"${vcos_include_dir}/${vcos_include}"
	done

	local bcm_includes
	bcm_includes="bcm_host.h"
	bcm_includes+=" EGL GLES GLES2 IL"
	bcm_includes+=" interface KHR"
	bcm_includes+=" vcinclude VG"
	for bcm_include in ${bcm_includes}; do
		dosym /opt/vc/include/${bcm_include} /usr/include/${bcm_include}
	done

	insinto /etc/env.d
	newins "${FILESDIR}"/etc-env.d-02bcm2835-libs 02bcm2835-libs
}
