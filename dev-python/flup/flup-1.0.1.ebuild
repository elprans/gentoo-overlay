# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/flup/flup-1.0.1.ebuild,v 1.1 2008/12/07 00:10:59 patrick Exp $

NEED_PYTHON=2.4

inherit distutils

KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86"

DESCRIPTION="Random assortment of WSGI servers"
HOMEPAGE="http://www.saddi.com/software/flup/"
SRC_URI="http://www.saddi.com/software/${PN}/dist/${PN}-${ORIG_PV}.tar.gz"
LICENSE="BSD"
SLOT="0:${PYTHON_SLOT_VERSION}"
IUSE=""

DEPEND="dev-python/setuptools:${SLOT}"
RDEPEND=""

S="${WORKDIR}/${PN}-${ORIG_PV}"

src_unpack() {
    distutils_src_unpack
    
    epatch "${FILESDIR}/2to3.patch"
}
