# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Simple wrapper for Python WSGI server"
HOMEPAGE="http://blog.coderazor.org/"
SRC_URI="http://gentoo.coderazor.org/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=">=dev-lang/python-2.4
		>=dev-python/flup-1.0"
RDEPEND="${DEPEND}"

src_install() {
	cd "${S}"
	dobin python-cgi-server || die
	cd "${S}/init-scripts/gentoo"
	newinitd python-cgi-server.initd python-cgi-server || die
	newconfd python-cgi-server.confd python-cgi-server || die
}
