# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

USE_RUBY="ruby19"

inherit ruby-fakegem

DESCRIPTION="Character encoding detection, brought to you by ICU"
HOMEPAGE="http://github.com/brianmario/charlock_holmes"
SRC_URI="http://github.com/brianmario/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

RUBY_S="brianmario-${PN}-*"
