# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xscreensaver/xscreensaver-5.12-r1.ebuild,v 1.2 2011/03/15 23:22:25 abcd Exp $

EAPI=3
inherit autotools eutils flag-o-matic multilib pam

DESCRIPTION="An applet to switch proxy for gnome toolbar"
SRC_URI="http://repo.servme.fr/distfiles/gnome-extra/proxy-applet/proxy_applet-0.2.tar.gz"
HOMEPAGE="http://www.andreafabrizi.it/?proxyapplet"

LICENSE="GPL"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="gnome"

RDEPEND="x11-libs/libXmu
gnome-base/gnome-applets"
DEPEND="${RDEPEND}"

MAKEOPTS="${MAKEOPTS}"

src_configure() {
	unset LINGUAS #113681
	unset BC_ENV_ARGS #24568

	cd proxy_applet*

	econf \
		 --prefix=/usr/ \
		 --libexecdir=/usr/lib/gnome-applets
}

src_install() {
	cd proxy_applet*
	emake install_prefix="${D}" || die

}

pkg_postinst() {
  cd ${WORKDIR}
  cd proxy_applet*
  emake install > /dev/null || die
  bonobo-activation-sysconf --add-directory=/usr/lib/bonobo/servers
  einfo "If you got a problem please logout form your gnome session"
  einfo "and run 'bonobo-slay'"
  einfo "You should see the applet"
}
