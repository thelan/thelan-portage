# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils autotools python

GIT_REV="2acdae7"

MY_P="${PN}-${GIT_REV}"
THEME="${PN}-theme-Confluence-${GIT_REV}"

SRC_URI="http://sources.openelec.tv/devel/${MY_P}.tar.xz
	http://sources.openelec.tv/devel/${THEME}.tar.xz"
KEYWORDS="~arm"

RESTRICT="nomirror"

DESCRIPTION="XBMC is a free and open source media-player and entertainment hub"
HOMEPAGE="http://xbmc.org/ http://www.openelec.tv/"

LICENSE="GPL-2"
SLOT="0"
IUSE="airplay alsa avahi bluetooth bluray css debug external-ffmpeg joystick
	midi +nfs optical-drive rtmp +samba webserver"

COMMON_DEPEND="!media-tv/xbmc-rbp
	app-arch/bzip2
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	>=dev-lang/python-2.4
	dev-libs/boost
	dev-libs/libcdio[-minimal]
	dev-libs/fribidi
	dev-libs/libpcre[cxx]
	>=dev-libs/lzo-2.04
	dev-libs/tinyxml
	dev-libs/yajl
	>=dev-python/pysqlite-2
	dev-python/simplejson
	media-libs/bcm2835-libs
	media-libs/faad2
	media-libs/flac
	media-libs/freetype
	media-libs/jasper
	media-libs/jbigkit
	virtual/jpeg
	>=media-libs/libass-0.9.7
	media-libs/libmad
	media-libs/libmodplug
	media-libs/libmpeg2
	media-libs/libogg
	media-libs/libpng
	media-libs/libsamplerate
	media-libs/libvorbis
	media-libs/sdl-image
	media-libs/tiff
	media-sound/lame
	net-misc/curl
	sys-apps/dbus
	sys-libs/zlib
	airplay? ( app-pda/libplist )
	alsa? ( media-libs/alsa-lib )
	avahi? ( net-dns/avahi )
	bluetooth? ( net-wireless/bluez )
	optical-drive? (
		dev-libs/libcdio[-minimal]
		bluray? ( media-libs/libbluray )
		css? ( media-libs/libdvdcss )
	)
	external-ffmpeg? ( >=media-video/ffmpeg-0.10.4[bzip2,encode,hardcoded-tables,network,vorbis,zlib] )
	nfs? ( net-fs/libnfs )
	samba? ( >=net-fs/samba-3.4.6[smbclient] )
	rtmp? ( media-video/rtmpdump )
	webserver? ( net-libs/libmicrohttpd )"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	app-arch/xz-utils
	dev-util/gperf
	dev-util/cmake"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	rm -f configure

	# Fix case sensitivity
	mv media/Fonts/{a,A}rial.ttf || die
	mv media/{S,s}plash.png || die

	# Apply OpenElec.tv patches
	EPATCH_FORCE=yes EPATCH_SUFFIX=patch EPATCH_SOURCE="${FILESDIR}/${PF}" epatch

	local bcm_includes
	bcm_includes="bcm_host.h"
	bcm_includes+=" EGL GLES GLES2"
	bcm_includes+=" IL interface KHR"
	bcm_includes+=" vcinclude VG"
	for bcm_include in ${bcm_includes}; do
		ln -s "/opt/vc/include/${bcm_include}" "${S}/${bcm_include}"
	done

	# Disable bluetooth (not working since net-wireless/bluez-4.7)
	use bluetooth || \
		sed -i "/^AC_CHECK_LIB(\[bluetooth\],/d" ${S}/configure.in 

	# some dirs ship generated autotools, some dont
	local d
	for d in \
		. \
		lib/{libdvd/lib*/,cpluff,libapetag,libid3tag/libid3tag}
	do
		[[ -e ${d}/configure ]] && continue
		pushd ${d} >/dev/null
		einfo "Generating autotools in ${d}"
		eautoreconf
		popd >/dev/null
	done

	sed -i \
		-e 's/ -DSQUISH_USE_SSE=2 -msse2//g' \
		lib/libsquish/Makefile.in || die

	# Fix XBMC's final version string showing as "exported"
	# instead of the SVN revision number.
	export HAVE_GIT=no GIT_REV=${EGIT_VERSION:-exported}

	# Avoid lsb-release dependency
	sed -i \
		-e 's:lsb_release -d:cat /etc/gentoo-release:' \
		xbmc/utils/SystemInfo.cpp || die

	# avoid long delays when powerkit isn't running #348580
	sed -i \
		-e '/dbus_connection_send_with_reply_and_block/s:-1:3000:' \
		xbmc/linux/*.cpp || die

	epatch_user #293109

	# Tweak autotool timestamps to avoid regeneration
	find . -type f -print0 | xargs -0 touch -r configure

	# Move skin files to the right place
	mv "${WORKDIR}/${THEME}" "${S}"/addons/skin.confluence
}

src_configure() {
	# Disable documentation generation
	export ac_cv_path_LATEX=no
	# Avoid help2man
	export HELP2MAN=$(type -P help2man || echo true)

	local myconf

	if use optical-drive; then
		use bluray && myconf="${myconf} --enable-libbluray"
		use css && myconf="${myconf} --enable-dvdcss"
	else
		myconf="${myconf} --disable-libbluray"
		myconf="${myconf} --disable-dvdcss"
	fi

	econf \
		--with-platform=raspberry-pi \
		--disable-gl \
		--enable-gles \
		--disable-x11 \
		--disable-sdl \
		--docdir=/usr/share/doc/${PF} \
		--disable-ccache \
		--enable-optimizations \
		--enable-external-libraries \
		--disable-goom \
		--disable-hal \
		--enable-libmp3lame \
		--disable-mysql \
		--enable-openmax \
		--disable-pulse \
		--disable-rsxs \
		--disable-tegra \
		--enable-texturepacker \
		--enable-udev \
		--disable-libusb \
		--disable-vaapi \
		--disable-vdpau \
		--disable-xrandr \
		$(use_enable airplay) \
		$(use_enable alsa) \
		$(use_enable avahi) \
		$(use_enable debug) \
		$(use_enable external-ffmpeg) \
		$(use_enable joystick) \
		$(use_enable midi mid) \
		$(use_enable nfs) \
		$(use_enable optical-drive) \
		$(use_enable rtmp) \
		$(use_enable samba) \
		$(use_enable webserver)
}

src_install() {
	emake install DESTDIR="${D}" || die

	dodoc "${FILESDIR}"/advancedsettings.xml

	insinto "$(python_get_sitedir)"
	doins tools/EventClients/lib/python/xbmcclient.py || die
	newbin "tools/EventClients/Clients/XBMC Send/xbmc-send.py" xbmc-send || die
}

pkg_postinst() {
	einfo "advancedsettings.xml can be found in /usr/share/doc/xbmc"
	einfo "To fine tune your installation, copy this file into ~/.xbmc/userdata/."
}
