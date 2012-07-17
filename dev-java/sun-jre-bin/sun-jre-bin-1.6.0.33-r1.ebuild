# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jre-bin/sun-jre-bin-1.6.0.33-r1.ebuild,v 1.2 2012/07/14 21:06:29 jdhore Exp $

EAPI="4"

inherit java-vm-2 eutils prefix versionator

MY_PV="$(get_version_component_range 2)u$(get_version_component_range 4)"
S_PV="$(replace_version_separator 3 '_')"

X86_AT="jre-${MY_PV}-linux-i586.bin"
AMD64_AT="jre-${MY_PV}-linux-x64.bin"
IA64_AT="jre-${MY_PV}-linux-ia64.bin"

DESCRIPTION="Oracle's Java SE Runtime Environment"
HOMEPAGE="http://www.oracle.com/technetwork/java/javase/"
SRC_URI="
	amd64? ( http://repo.servme.fr/distfiles/${CATEGORY}/${PN}/${AMD64_AT} )
	ia64? ( http://repo.servme.fr/distfiles/${CATEGORY}/${PN}/${IA64_AT} )
	x86? ( http://repo.servme.fr/distfiles/${CATEGORY}/${PN}/${X86_AT} )"

LICENSE="Oracle-BCLA-JavaSE"
SLOT="1.6"
KEYWORDS="~amd64 x86"

IUSE="X alsa jce nsplugin"

RESTRICT="strip"

RDEPEND="
	X? (
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXrender
		x11-libs/libXtst
		x11-libs/libX11
	)
	alsa? ( media-libs/alsa-lib )
	jce? ( dev-java/sun-jce-bin:1.6 )
	!prefix? ( sys-libs/glibc )"

S="${WORKDIR}/jre${S_PV}"

src_unpack() {
	sh "${DISTDIR}"/${A} -noregister || die "Failed to unpack"
}

src_compile() {
	# This needs to be done before CDS - #215225
	java-vm_set-pax-markings "${S}"

	# see bug #207282
	einfo "Creating the Class Data Sharing archives"
	if use x86; then
		bin/java -client -Xshare:dump || die
	fi
	# limit heap size for large memory on x86 #405239
	# this is a workaround and shouldn't be needed.
	bin/java -server -Xmx64m -Xshare:dump || die
}

src_install() {
	# We should not need the ancient plugin for Firefox 2 anymore, plus it has
	# writable executable segments
	if use x86; then
		rm -vf lib/i386/libjavaplugin_oji.so \
			lib/i386/libjavaplugin_nscp*.so
		rm -vrf plugin/i386
	fi
	# Without nsplugin flag, also remove the new plugin
	local arch=${ARCH};
	use x86 && arch=i386;
	if ! use nsplugin; then
		rm -vf lib/${arch}/libnpjp2.so \
			lib/${arch}/libjavaplugin_jni.so
	fi

	dodir /opt/${P}
	cp -pPR bin lib man "${ED}"/opt/${P} || die

	# Remove empty dirs we might have copied
	find "${D}" -type d -empty -exec rmdir {} + || die

	dodoc COPYRIGHT README

	if use jce; then
		dodir /opt/${P}/lib/security/strong-jce
		mv "${ED}"/opt/${P}/lib/security/US_export_policy.jar \
			"${ED}"/opt/${P}/lib/security/strong-jce || die
		mv "${ED}"/opt/${P}/lib/security/local_policy.jar \
			"${ED}"/opt/${P}/lib/security/strong-jce || die
		dosym /opt/sun-jce-bin-1.6.0/jre/lib/security/unlimited-jce/US_export_policy.jar \
			/opt/${P}/lib/security/US_export_policy.jar
		dosym /opt/sun-jce-bin-1.6.0/jre/lib/security/unlimited-jce/local_policy.jar \
			/opt/${P}/lib/security/local_policy.jar
	fi

	if use nsplugin; then
		install_mozilla_plugin /opt/${P}/lib/${arch}/libnpjp2.so
	fi

	# Install desktop file for the Java Control Panel.
	# Using ${PN}-${SLOT} to prevent file collision with jre and or other slots.
	# make_desktop_entry can't be used as ${P} would end up in filename.
	newicon lib/desktop/icons/hicolor/48x48/apps/sun-jcontrol.png \
		sun-jcontrol-${PN}-${SLOT}.png || die
	sed -e "s#Name=.*#Name=Java Control Panel for Oracle JDK ${SLOT} (${PN})#" \
		-e "s#Exec=.*#Exec=/opt/${P}/bin/jcontrol#" \
		-e "s#Icon=.*#Icon=sun-jcontrol-${PN}-${SLOT}.png#" \
		lib/desktop/applications/sun_java.desktop > \
		"${T}"/jcontrol-${PN}-${SLOT}.desktop || die
	domenu "${T}"/jcontrol-${PN}-${SLOT}.desktop

	# bug #56444
	cp "${FILESDIR}"/fontconfig.Gentoo.properties-r1 "${T}"/fontconfig.properties || die
	eprefixify "${T}"/fontconfig.properties
	insinto /opt/${P}/lib/
	doins "${T}"/fontconfig.properties

	set_java_env "${FILESDIR}/${VMHANDLE}.env-r1"
	java-vm_revdep-mask
}

QA_TEXTRELS_x86="
	opt/${P}/lib/i386/client/libjvm.so
	opt/${P}/lib/i386/motif21/libmawt.so
	opt/${P}/lib/i386/server/libjvm.so"
QA_FLAGS_IGNORED="
	/opt/${P}/bin/java
	/opt/${P}/bin/java_vm
	/opt/${P}/bin/javaws
	/opt/${P}/bin/keytool
	/opt/${P}/bin/orbd
	/opt/${P}/bin/pack200
	/opt/${P}/bin/policytool
	/opt/${P}/bin/rmid
	/opt/${P}/bin/rmiregistry
	/opt/${P}/bin/servertool
	/opt/${P}/bin/tnameserv
	/opt/${P}/bin/unpack200
	/opt/${P}/lib/jexec"
for java_system_arch in amd64 i386; do
	QA_FLAGS_IGNORED+="
		/opt/${P}/lib/${java_system_arch}/headless/libmawt.so
		/opt/${P}/lib/${java_system_arch}/jli/libjli.so
		/opt/${P}/lib/${java_system_arch}/libawt.so
		/opt/${P}/lib/${java_system_arch}/libcmm.so
		/opt/${P}/lib/${java_system_arch}/libdcpr.so
		/opt/${P}/lib/${java_system_arch}/libdeploy.so
		/opt/${P}/lib/${java_system_arch}/libdt_socket.so
		/opt/${P}/lib/${java_system_arch}/libfontmanager.so
		/opt/${P}/lib/${java_system_arch}/libhprof.so
		/opt/${P}/lib/${java_system_arch}/libinstrument.so
		/opt/${P}/lib/${java_system_arch}/libioser12.so
		/opt/${P}/lib/${java_system_arch}/libj2gss.so
		/opt/${P}/lib/${java_system_arch}/libj2pcsc.so
		/opt/${P}/lib/${java_system_arch}/libj2pkcs11.so
		/opt/${P}/lib/${java_system_arch}/libjaas_unix.so
		/opt/${P}/lib/${java_system_arch}/libjava_crw_demo.so
		/opt/${P}/lib/${java_system_arch}/libjavaplugin_jni.so
		/opt/${P}/lib/${java_system_arch}/libjava.so
		/opt/${P}/lib/${java_system_arch}/libjawt.so
		/opt/${P}/lib/${java_system_arch}/libJdbcOdbc.so
		/opt/${P}/lib/${java_system_arch}/libjdwp.so
		/opt/${P}/lib/${java_system_arch}/libjpeg.so
		/opt/${P}/lib/${java_system_arch}/libjsig.so
		/opt/${P}/lib/${java_system_arch}/libjsoundalsa.so
		/opt/${P}/lib/${java_system_arch}/libjsound.so
		/opt/${P}/lib/${java_system_arch}/libmanagement.so
		/opt/${P}/lib/${java_system_arch}/libmlib_image.so
		/opt/${P}/lib/${java_system_arch}/libnative_chmod_g.so
		/opt/${P}/lib/${java_system_arch}/libnative_chmod.so
		/opt/${P}/lib/${java_system_arch}/libnet.so
		/opt/${P}/lib/${java_system_arch}/libnio.so
		/opt/${P}/lib/${java_system_arch}/libnpjp2.so
		/opt/${P}/lib/${java_system_arch}/libnpt.so
		/opt/${P}/lib/${java_system_arch}/librmi.so
		/opt/${P}/lib/${java_system_arch}/libsplashscreen.so
		/opt/${P}/lib/${java_system_arch}/libunpack.so
		/opt/${P}/lib/${java_system_arch}/libverify.so
		/opt/${P}/lib/${java_system_arch}/libzip.so
		/opt/${P}/lib/${java_system_arch}/motif21/libmawt.so
		/opt/${P}/lib/${java_system_arch}/native_threads/libhpi.so
		/opt/${P}/lib/${java_system_arch}/server/libjvm.so
		/opt/${P}/lib/${java_system_arch}/xawt/libmawt.so"
done
