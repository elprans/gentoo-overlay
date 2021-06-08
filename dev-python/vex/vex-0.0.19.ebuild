# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6,7,8,9} )

inherit distutils-r1 eutils

DESCRIPTION="Run a command in the named virtualenv"
HOMEPAGE="https://pypi.python.org/pypi/vex"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="dev-python/virtualenv[$PYTHON_USEDEP]"
PATCHES="${FILESDIR}/shell-run.patch"
