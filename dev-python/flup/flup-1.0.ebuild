# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/flup/flup-0.5_p2307.ebuild,v 1.5 2007/07/26 18:15:47 corsair Exp $

NEED_PYTHON=2.4

inherit distutils

KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86"

DESCRIPTION="Random assortment of WSGI servers, middleware"
HOMEPAGE="http://www.saddi.com/software/flup/"
SRC_URI="http://www.saddi.com/software/${PN}/dist/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
IUSE=""

DEPEND="dev-python/setuptools"

S="${WORKDIR}/${P}"
