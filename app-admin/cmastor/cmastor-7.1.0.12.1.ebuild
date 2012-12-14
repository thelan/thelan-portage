DESCRIPTION="hp Server Management Drivers and Agents."
HOMEPAGE="http://h18000.www1.hp.com/products/servers/linux/documentation.html"
LICENSE="hp-value"

DEPEND="${RDEPEND}
		hpasm"
	

PACKAGE="cmastor-7.1.0-12.linux.i386"
SRC_URI="ftp://ftp.compaq.com/pub/products/servers/supportsoftware/linux/${PACKAGE}.rpm"

IUSE=""
SLOT="0"
KEYWORDS="x86"
S="${WORKDIR}"

src_unpack() {
	cd ${S}
	rpm2targz ${DISTDIR}/${PACKAGE}.rpm
	tar zxpf ${S}/${PACKAGE}.tar.gz > /dev/null 2>&1
}

src_install() {


	CMASTOR_HOME="/opt/compaq"

	dodir ${CMASTOR_HOME}

	cp -Rdp \
	opt/compaq/* \
	${D}${CMASTOR_HOME}


	exeinto /etc/init.d
	doexe ${FILESDIR}/cmastor || die



	for i in opt/compaq/storage/etc/cmalib \
			 

	do
	cat ${D}/$i | \
	sed 's/VENDOR="Unknown"/VENDOR="RedHat"/' >\
	${D}/$i-new
	mv ${D}/$i-new ${D}/$i

    cat ${D}/$i | \
    sed 's/\.\ \/etc\/init.d\/functions/\.\ \/opt\/compaq\/hpasm\/etc\/functions/' >\
	${D}/$i-new
	mv ${D}/$i-new ${D}/$i
			
	cat ${D}/$i | \
    sed 's/\.\ \/etc\/rc.d\/init.d\/functions/\.\ \/opt\/compaq\/hpasm\/etc\/functions/' >\
	${D}/$i-new
	mv ${D}/$i-new ${D}/$i
			
	chmod 755 ${D}/$i
	done

}

pkg_postinst() {

	if test -e /dev/cciss/disc0/disc
    then
	    ln -s /dev/cciss/disc0/disc /dev/cciss/c0d0
	else
		ln -s /dev/ida/disc0/disc /dev/ida/c0d0
	fi
					
	einfo ""
	einfo "dont forget!"
	einfo "rc-update add cmastor default"
	einfo ""
}
