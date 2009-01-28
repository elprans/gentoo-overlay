# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit distutils

DESCRIPTION="reST to ODT translator"
HOMEPAGE="http://www.rexx.com/~dkuhlman/odtwriter.html"
SRC_URI="http://www.rexx.com/~dkuhlman/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=""
RDEPEND="dev-python/docutils"

PYTHON_MODNAME="odtwriter"
