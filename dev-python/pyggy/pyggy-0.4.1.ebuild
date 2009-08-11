# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:$

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

KEYWORDS="amd64 ~ia64 ~ppc ~x86"

DESCRIPTION="Python Lex-Yacc library"
SRC_URI="http://www.lava.net/~newsham/pyggy/${P}.tar.gz"
HOMEPAGE="http://www.lava.net/~newsham/pyggy/"
LICENSE="public-domain"
SLOT="0"
IUSE=""

src_prepare() {
	epatch "${FILESDIR}/pyggy.patch"
}

src_install() {
	DOCS="README TODO"
	distutils_src_install
}
