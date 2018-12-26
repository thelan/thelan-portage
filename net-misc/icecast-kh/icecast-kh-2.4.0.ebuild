# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools systemd user

DESCRIPTION="Opensource alternative to shoutcast that supports mp3, ogg and aac streaming - From karlheyes"
HOMEPAGE="https://github.com/karlheyes/icecast-kh"
SRC_URI="https://github.com/karlheyes/icecast-kh/archive/icecast-${PV}-kh10.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 x86 ~x86-fbsd"
IUSE="kate libressl logrotate +speex +ssl +theora +yp"

#Although there is a --with-ogg and --with-orbis configure option, they're
#only useful for specifying paths, not for disabling.
DEPEND="
	dev-libs/libxml2
	dev-libs/libxslt
	media-libs/libogg
	media-libs/libvorbis
	kate? ( media-libs/libkate )
	logrotate? ( app-admin/logrotate )
	speex? ( media-libs/speex )
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)
	theora? ( media-libs/libtheora )
	yp? ( net-misc/curl )
"
RDEPEND="${DEPEND}
	!!net-misc/icecast"

PATCHES=(
	# bug #368539
	#"${FILESDIR}"/icecast-2.3.3-libkate.patch
	# bug #430434
	"${FILESDIR}"/icecast-2.3.3-fix-xiph_openssl.patch
	# Custom patch
    # "${FILESDIR}"/icecast-2.4.2-user-agent.patch
)

pkg_setup() {
	enewuser icecast -1 -1 -1 nogroup
}

src_unpack() {
	if [ "${A}" != "" ]; then
		unpack ${A}
		if [ ! -d icecast-kh-2.4.0 ]; then
			mv *icecast* icecast-kh-2.4.0
		fi
	fi
}

src_prepare() {
	default
	#eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-dependency-tracking
		--docdir=/usr/share/doc/${PF}
		--sysconfdir=/etc/icecast2
		$(use_enable kate)
		$(use_enable yp)
		$(use_with speex)
		$(use_with ssl openssl)
		$(use_with theora)
		$(use_with yp curl)
	)
	econf "${myeconfsrgs[@]}"
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS README TODO HACKING NEWS conf/icecast.xml.dist
	docinto html
	dodoc doc/*.html

	newinitd "${FILESDIR}"/icecast.initd ${PN}
	systemd_dounit "${FILESDIR}"/icecast.service

	insinto /etc/icecast2
	doins "${FILESDIR}"/icecast.xml
	fperms 600 /etc/icecast2/icecast.xml

	if use logrotate; then
		dodir /etc/logrotate.d
		insopts -m0644
		insinto /etc/logrotate.d
		newins "${FILESDIR}"/icecast.logrotate ${PN}
	fi
	diropts -m0764 -o icecast -g nogroup
	dodir /var/log/icecast
	keepdir /var/log/icecast
	rm -r "${ED}"/usr/share/doc/icecast || die
}

pkg_postinst() {
	touch "${ROOT}"/var/log/icecast/{access,error}.log
	chown icecast:nogroup "${ROOT}"/var/log/icecast/{access,error}.log
}
