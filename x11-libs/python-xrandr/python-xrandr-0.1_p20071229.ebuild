# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="3"

SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND="2:2.6"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils eutils

DESCRIPTION="Python bindings for Xrandr"
HOMEPAGE="https://launchpad.net/python-xrandr"
SRC_URI="http://gentoo.coderazor.org/${P}.tar.bz2"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND=">=x11-libs/libXrandr-1.2"

PYTHON_MODNAME="xrandr"

src_prepare() {
	epatch "${FILESDIR}/gamma.patch" || die "epatch failed"
}
