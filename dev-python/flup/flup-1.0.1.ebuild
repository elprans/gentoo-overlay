# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"
NEED_PYTHON=2.4

inherit distutils

KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86"

DESCRIPTION="Random assortment of WSGI servers"
HOMEPAGE="http://www.saddi.com/software/flup/"
SRC_URI="http://www.saddi.com/software/${PN}/dist/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND=""

src_unpack() {
	distutils_src_unpack
	epatch "${FILESDIR}/2to3.patch"
}
