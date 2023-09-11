# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9,10,11} )

inherit distutils-r1

DESCRIPTION="Run a command in the named virtualenv"
HOMEPAGE="https://pypi.python.org/pypi/vex"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="dev-python/virtualenv[$PYTHON_USEDEP]"
PATCHES="${FILESDIR}/shell-run.patch"
