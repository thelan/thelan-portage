# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="lFowd is a small, fast and secure NetFlow collector"
HOMEPAGE="http://www.mindrot.org/projects/flowd/"
SRC_URI="http://www.mindrot.org/files/flowd/flowd-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-util/byacc"

src_configure() {
	econf --localstatedir=/var
}

src_install() {
        emake DESTDIR="${D}" install || die "emake install failed"
        dodoc ChangeLog README PLATFORMS || die "dodoc failed"
	keepdir /var/empty
	newinitd "${FILESDIR}"/flowd-init.d flowd || die "newinitd failed"
}

pkg_setup() {
        enewgroup _flowd
        enewuser _flowd -1 -1 /var/empty _flowd
}
