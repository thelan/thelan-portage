EAPI="4"

DESCRIPTION="Scripts to properly build and install a kernel on the Raspberry PI"
HOMEPAGE="https://www.github.com/tkurbad/raspberrypi-overlay"
SRC_URI=""

SLOT="0"
KEYWORDS="arm"
IUSE="+distcc"

RDEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
	cd "${WORKDIR}"

	exeinto /root/bin
	doexe "${FILESDIR}/0.0.4/installkernel"

	exeinto /usr/bin
	doexe "${FILESDIR}/0.0.4/raspberrypi-genkernel"

	if use distcc; then
		sed -i "s/##DISTCC##/\/usr\/lib\/distcc\/bin\/${CHOST}-/g" \
			"${D}/usr/bin/raspberrypi-genkernel" \
			|| die "sed failed."
	else
		sed -i "s/##DISTCC##//g" \
			"${D}/usr/bin/raspberrypi-genkernel" \
			|| die "sed failed."
	fi
}
