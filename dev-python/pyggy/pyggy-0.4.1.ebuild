# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/ply/ply-2.3.ebuild,v 1.2 2007/07/03 10:39:28 lucass Exp $

inherit distutils

KEYWORDS="amd64 ~ia64 ~ppc ~x86"

DESCRIPTION="Python Lex-Yacc library"
SRC_URI="http://www.lava.net/~newsham/pyggy/${PN}-${ORIG_PV}.tar.gz"
HOMEPAGE="http://www.lava.net/~newsham/pyggy/"
LICENSE="public-domain"
SLOT="0:${PYTHON_SLOT_VERSION}"
IUSE=""

S="${WORKDIR}/${PN}-${ORIG_PV}"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}/pyggy.patch"
}

src_install() {
	DOCS="README TODO"
	distutils_src_install
}
