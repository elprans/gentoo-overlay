# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{7,8,9} )

inherit distutils-r1

DESCRIPTION="Capture the outcome of Python function calls"
HOMEPAGE="https://github.com/python-trio/outcome"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
LICENSE="MIT Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-python/attrs-19.2.0[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"

RESTRICT="test"
