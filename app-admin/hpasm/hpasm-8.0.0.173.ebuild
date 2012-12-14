# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs versionator linux-info

DESCRIPTION="HP System Health Application and Insight Management Agents Package"
HOMEPAGE="http://h18000.www1.hp.com/products/servers/linux/documentation.html"
LICENSE="hp-value"
KEYWORDS="amd64 x86"
IUSE="ssl snmp X"
DEPEND="${RDEPEND}
        mail-client/mailx
        app-arch/rpm2targz
        sys-apps/pciutils
        sys-libs/ncurses
        dev-lang/python
        sys-apps/ethtool
        sys-apps/lm_sensors
        sys-libs/lib-compat
        snmp? ( net-analyzer/net-snmp )
        ssl? ( dev-libs/openssl )
        X? ( virtual/x11 dev-tcltk/tclx dev-tcltk/tix )"

RDEPEND="${DEPEND}
        app-arch/tar
        sys-apps/sed"

SRC_URI_BASE="ftp://ftp.hp.com/pub/softlib2/software1/pubsw-linux"
SRC_URI="x86? ( ${SRC_URI_BASE}/p1925054526/v42992/${PN}-$(replace_version_separator 3 '-').rhel5.i386.rpm )
                amd64? ( ${SRC_URI_BASE}/p315823469/v43005/${PN}-$(replace_version_separator 3 '-').rhel5.x86_64.rpm )"

HPASM_HOME="/opt/compaq"
HPASMHP_HOME="/opt/hp"

RESTRICT="${RESTRICT} strip"
QA_TEXTRELS="lib/libcpqci.so.1.0
lib/libcpqipmb.so.1.0"
QA_EXECSTACK="lib/libhpev.so.1.0
${HPASM_HOME:1}/foundation/bin/cmahostd
${HPASM_HOME:1}/foundation/bin/cmapeerd
${HPASM_HOME:1}/foundation/bin/cmathreshd
${HPASM_HOME:1}/hpasmd/bin/IrqRouteTbl
${HPASM_HOME:1}/hpasmd/bin/hpasmd
${HPASM_HOME:1}/hpasmd/bin/hpasmlited
${HPASM_HOME:1}/hpasmd/bin/hpasmxld
${HPASM_HOME:1}/server/bin/cmasm2d
${HPASM_HOME:1}/server/bin/cmastdeqd
${HPASM_HOME:1}/storage/bin/cmaeventd
${HPASM_HOME:1}/storage/bin/cmafcad
${HPASM_HOME:1}/storage/bin/cmaidad
${HPASM_HOME:1}/storage/bin/cmaided
${HPASM_HOME:1}/storage/bin/cmasasd
${HPASM_HOME:1}/storage/bin/cmascsid
${HPASM_HOME:1}/utils/hplog
${HPASMHP_HOME:1}/hpsmh/data/webapp-data/webagent/csginkgo"

SLOT="0"
S="${WORKDIR}"

pkg_setup() {
        linux-info_pkg_setup
        if ! [ ${KV_MAJOR} -eq 2 -a ${KV_MINOR} -gt 5 ] ; then
                die "Kernel not supported. You need a kernel >= 2.6.0."
        fi
}

src_unpack() {
        cd "${S}"
        rpm2targz "${DISTDIR}/${A}" || die "rpm2targz failed"
        tar zxpf ${PN}-$(replace_version_separator 3 '-').rhel5.*.tar.gz >/dev/null 2>&1 || die "unpacking archive failed"
        rm -f ${PN}-$(replace_version_separator 3 '-').rhel5.*.tar.gz >/dev/null 2>&1
}

src_install() {
        cd "${S}"

        dodir ${HPASM_HOME}
        cp -Rdp "${S}"${HPASM_HOME}/* "${D}"${HPASM_HOME}

        dodir ${HPASMHP_HOME}
        cp -Rdp "${S}"${HPASMHP_HOME}/* "${D}"${HPASMHP_HOME}

        dodir /etc
        cp ${FILESDIR}/initlog.conf "${D}"/etc

        exeinto ${HPASM_HOME}/hpasm/etc
        doexe ${FILESDIR}/functions || die

        into /
        cp ${FILESDIR}/initlog .
        dosbin initlog


        #
        cat <<EOF > "${T}"/45${PN}-${SLOT}
PATH=${HPASM_HOME}/foundation/bin:${HPASM_HOME}/hpasmd/bin:${HPASM_HOME}/nic/bin:${HPASM_HOME}/server/bin:${HPASM_HOME}/storage/bin:${HPASM_HOME}/utils
ROOTPATH=${HPASM_HOME}/hpasmd/bin
LDPATH=${HPASM_HOME}/storage/bin
CONFIG_PROTECT="${HPASM_HOME}/foundation/etc ${HPASM_HOME}/hpasm/etc ${HPASM_HOME}/hpasmd/etc ${HPASM_HOME}/server/etc ${HPASM_HOME}/storage/etc"
EOF
        doenvd "${T}"/45${PN}-${SLOT} || die "Failed installing env.d script"

        for foo in ./usr/$(get_libdir)/*.so.*.* ; do
                local so_name=$(basename ${foo})
                local so_mayor=$(echo ${so_name}|sed -n "s:^.*\.so\.\([0-9]*\)\.\([0-9]*\)$:\1:p")
                local so_minor=$(echo ${so_name}|sed -n "s:^.*\.so\.\([0-9]*\)\.\([0-9]*\)$:\2:p")
                if [ -n "${so_mayor}" -a -n "${so_minor}" ]; then
                        ln -sf ${so_name}.${so_mayor}.${so_minor} ${so_name}.${so_mayor}
                        ln -sf ${so_name}.${so_mayor} ${so_name}
                fi
        done
        dolib.so ./usr/$(get_libdir)/*.so*

        for foo in ./${HPASM_HOME}/utils/* ; do
                dosym ${HPASM_HOME}/utils/$(basename ${foo}) /sbin/$(basename ${foo})
        done

#       if [ ! -f ${ROOT}/usr/share/snmp/snmpd.conf ]; then
#               insinto /usr/share/snmp
#               doins ${FILESDIR}/snmpd.conf || die
#       else
#               insinto /usr/share/snmp
#               newins ${FILESDIR}/snmpd.conf snmpd.conf.cma || die
#       fi

        for foo in libcrypto.so.6 libnetsnmpagent.so.10 libnetsnmphelpers.so.10 \
                libnetsnmp.so.10 libnetsnmpmibs.so.10 ; do
                if [ ! -L "${ROOT}"/usr/$(get_libdir)/${foo} ] ; then
                        if [ -L "${ROOT}"/usr/$(get_libdir)/${foo%.*} ] ; then
                                dosym /usr/$(get_libdir)/${foo%.*} /usr/$(get_libdir)/${foo}
                        fi
                fi
        done

#       if [ ! -f "${ROOT}"/usr/$(get_libdir)/libssl.so.2 ]; then
#               dosym /usr/$(get_libdir)/$(basename $(ls --color=no -1 "${ROOT}"/usr/$(get_libdir)/libssl.so.*|head -n 1)) libssl.so.2
#       fi

        sed -i -e "s:^\(.*[\t ]*\)u\(sleep[\t ]*\)\([1-9]\)00000[\t ]*$:\1\20.\3:g" \
                -i -e "s:^\(.*[\t ]*\)u\(sleep[\t ]*\)\([1-9][^0]\)0000[\t ]*$:\1\20.\3:g" \
                ${D}${HPASM_HOME}/hpasm/etc/functions

        sed -i -e "s:^\([\t ]*createdistrotxt\)[\t ]*\(().*\)$:\1_hporg\2:g" \
                ${D}${HPASM_HOME}/hpasm/etc/common.functions

        cat <<EOF >> "${D}"${HPASM_HOME}/hpasm/etc/common.functions
createdistrotxt()
{
        echo "Gentoo:2.x:2007" >/opt/compaq/hpasm/distro.txt
}
EOF

        dodir /var/spool/compaq
        dodir /var/spool/compaq/foundation
        dodir /var/spool/compaq/foundation/registry
        dodir /var/spool/compaq/server
        dodir /var/spool/compaq/server/registry
        fperms 0700 /var/spool/compaq
        fperms 0700 /var/spool/compaq/foundation
        fperms 0700 /var/spool/compaq/foundation/registry
        fperms 0700 /var/spool/compaq/server
        fperms 0700 /var/spool/compaq/server/registry

        exeinto /etc/init.d
        doinitd ${FILESDIR}/hpasm || die "Failed installing init.d script"

        doman usr/share/man/man?/*

#       echo "exclude cmhp"     >> ${D}${HPASM_HOME}/cma.conf
#       echo "trapemail /bin/mail -s 'HP Insight Management Agents Trap Alarm' root" >> ${D}${HPASM_HOME}/cma.conf

        echo "Gentoo:2.x:2008"  >>  ${D}${HPASM_HOME}/hpasm/distro.txt
##      echo "RELEASE=Unknown" >> ${D}${HPASM_HOME}/hpasm/distro.txt
##      echo "PRODUCT=Unknown" >> ${D}${HPASM_HOME}/hpasm/distro.txt

##      for i in ${HPASM_HOME}/foundation/etc/cmafdtnobjects.conf ${HPASM_HOME}/server/etc/cmasvrobjects.conf ${HPASM_HOME}/storage/etc/cmastorobjects.conf

##      do
##      echo $i >> ${D}${HPASM_HOME}/cmaobjects.conf
##      done
}

pkg_postinst() {
        if [ "${ROOT}" == "/" ] ; then
                /sbin/ldconfig
        fi
        einfo
        if ! use X ; then
                einfo "If you want to run cpqimlview you will"
                einfo "need to emerge X, tclx, and tix."
                einfo
        fi
        if ! use snmp ; then
                einfo "If you want to use the web agent and other features"
                einfo "then configure your /usr/share/snmp/snmpd.conf"
                einfo
                einfo "It is not required to have net-snmp"
                einfo "running for basic hpasm functionality."
                einfo
        fi
        einfo "You now need to execute /etc/init.d/hpasm configure"
        einfo "in order to configure the installed package."
        einfo
}
