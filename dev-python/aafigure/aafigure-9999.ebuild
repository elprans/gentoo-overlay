# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit distutils subversion

DESCRIPTION="reST aafigure directive"
HOMEPAGE="http://docutils.sourceforge.net/sandbox/aafigure/"
SRC_URI=""
ESVN_REPO_URI="http://svn.berlios.de/svnroot/repos/docutils/trunk/sandbox/aafigure"

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=""
RDEPEND="dev-python/docutils"

S="${WORKDIR}/${PN}"

PYTHON_MODNAME="aafigure"

src_unpack() {
	subversion_src_unpack

	cd "${S}"
	rm -rf ez_setup*
	echo "def use_setuptools(*args, **kwargs): pass" > ez_setup.py
}
