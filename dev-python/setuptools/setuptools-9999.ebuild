# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/setuptools/setuptools-0.6_rc9.ebuild,v 1.1 2008/10/10 18:54:01 pythonhead Exp $

NEED_PYTHON="2.4"

inherit distutils eutils subversion

MY_P="${P/_rc/c}"

DESCRIPTION="A collection of enhancements to the Python distutils including easy install"
HOMEPAGE="http://peak.telecommunity.com/DevCenter/setuptools"
#SRC_URI="http://cheeseshop.python.org/packages/source/s/setuptools/${MY_P}.tar.gz"
ESVN_REPO_URI="http://svn.python.org/projects/sandbox/trunk/setuptools/"
LICENSE="PSF-2.2"
SLOT="0:${PYTHON_SLOT_VERSION}"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc
~sparc-fbsd ~x86 ~x86-fbsd"
IUSE=""

DOCS="EasyInstall.txt pkg_resources.txt setuptools.txt README.txt"

src_unpack() {
	subversion_src_unpack
	#distutils_src_unpack

	if [ "${PYTHON_SLOT_VERSION:0:1}" == "3" ]; then
	    epatch "${FILESDIR}/${PN}-python3-compat.patch"
    	    epatch "${FILESDIR}/${PN}-python3-compat-part2.patch"
	    epatch "${FILESDIR}/${PN}-python3-compat-part3.patch"
	fi
	
	# Remove tests that access the network (bugs #198312, #191117)
	rm setuptools/tests/test_packageindex.py
}

src_test() {
	PYTHONPATH="." "${python}" setup.py test || die "tests failed"
}
