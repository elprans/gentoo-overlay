# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit distutils

DESCRIPTION="Python bindings for Xrandr"
HOMEPAGE="https://launchpad.net/python-xrandr"
SRC_URI="http://launchpad.net/${PN}/stable/${PV}/+download/${P}.tar.gz"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND=">=x11-libs/libXrandr-1.2"

PYTHON_MODNAME="xrandr"
