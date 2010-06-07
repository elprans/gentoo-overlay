# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Lightweight in-process concurrent programming"
HOMEPAGE="http://bitbucket.org/ambroff/greenlet"
SRC_URI="http://pypi.python.org/packages/source/g/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=""
RDEPEND=""

PYTHON_MODNAME="greenlet"
