# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/cython/cython-0.9.8.1.1.ebuild,v 1.1 2008/10/20 14:34:03 hawking Exp $

inherit distutils eutils mercurial

MY_PN="Cython"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A language for writing Python extension modules based on pyrex"
HOMEPAGE="http://www.cython.org/"
#SRC_URI="http://www.cython.org/${MY_P}.tar.gz"
EHG_REPO_URI="http://hg.cython.org/cython-devel/"

LICENSE="PSF-2.4"
SLOT="0:${PYTHON_SLOT_VERSION}"
KEYWORDS="~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="doc examples"

DEPEND=""
RDEPEND=""

S="${WORKDIR}/cython-devel"

PYTHON_MODNAME="${MY_PN}"
DOCS="ToDo.txt USAGE.txt"

src_unpack() {
	mercurial_src_unpack
	cd "${S}"
	if [ "${PYTHON_SLOT_VERSION:0:1}" == "3" ]; then
	    epatch "${FILESDIR}/py3compat.patch"
	fi
}

src_install() {
	distutils_src_install

	# -A c switch is for Doc/primes.c
	use doc && dohtml -A c -r Doc/*

	if use examples; then
		# Demos/ has files with .so,~ suffixes.
		# So we have to specify precisely what to install.
		insinto /usr/share/doc/${PF}/examples
		doins Demos/Makefile* Demos/Setup.py Demos/*.{py,pyx,pxd}
	fi
}
