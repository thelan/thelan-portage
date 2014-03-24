# Copyright 1999-2008 Gentoo Foundation 2008-2008 Chris Gianelloni
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils autotools

REP_PV="2.2"
REP_PN="repcached"
REP_P="${REP_PN}-${REP_PV}"

MY_PV="${PV/_rc/-rc}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="High-performance, distributed memory object caching system"
HOMEPAGE="http://www.danga.com/memcached/"
SRC_URI="http://www.danga.com/memcached/dist/${MY_P}.tar.gz
	repcached? ( mirror://sourceforge/${REP_PN}/${REP_P}-${PV}.patch.gz )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="nptl repcached test"

RDEPEND=">=dev-libs/libevent-1.4
		 dev-lang/perl"
DEPEND="${RDEPEND}
		test? ( virtual/perl-Test-Harness >=dev-perl/Cache-Memcached-1.24 )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.2.2-fbsd.patch"
	if use repcached ; then
		epatch "${WORKDIR}/${REP_P}-${PV}.patch"
		eautoreconf
	fi
}

src_compile() {
	if use repcached && use nptl ; then
		ewarn "You cannot use threads and replication together.  Disabling thread support."
		myconf="--enable-replication --disable-threads"
	else
		myconf="$(use_enable nptl threads) $(use_enable repcached replication)"
	fi
	econf ${myconf}
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dobin scripts/memcached-tool

	dodoc AUTHORS ChangeLog NEWS README TODO doc/{CONTRIBUTORS,*.txt}

	if use repcached; then
		newconfd "${FILESDIR}"/memcached.confd-repcached memcached
		newinitd "${FILESDIR}"/memcached.rc-repcached memcached
	else
		newconfd "${FILESDIR}"/memcached.confd memcached
		newinitd "${FILESDIR}"/memcached.rc memcached
	fi
}

pkg_postinst() {
	enewuser memcached -1 -1 /dev/null daemon

	elog "This version of Memcached now supports multiple instances."
	elog "To enable this, you must create a symlink in /etc/init.d/ for each instance"
	elog "to /etc/init.d/memcached and create the matching conf files in /etc/conf.d/"
	elog "Please see Gentoo bug #122246 for more info"
}

src_test() {
	emake -j1 test || die "Failed testing"
}
