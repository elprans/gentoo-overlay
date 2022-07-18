# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{9,10} )

inherit distutils-r1

DESCRIPTION="A set of Python 3 bindings for libfuse 3"
HOMEPAGE="https://github.com/libfuse/pyfuse3"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

RDEPEND=">=dev-python/trio-0.15[${PYTHON_USEDEP}]
	sys-fs/fuse:3"
DEPEND="${RDEPEND}
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/pytest-trio[${PYTHON_USEDEP}]
		net-misc/rsync[xattr]
	)"

RESTRICT="test"

python_test() {
	addwrite /dev/fuse
	py.test -v tests || die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	distutils-r1_python_install_all

	if use doc ; then
		dodoc doc/manual.pdf
		dodoc -r doc/html
	fi
}
