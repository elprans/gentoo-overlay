# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

NEED_PYTHON=2.5
EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils multilib git

DESCRIPTION="Python refactoring library"
HOMEPAGE="http://rope.sourceforge.net/"
#SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
EGIT_REPO_URI="git://git.coderazor.org/elvis/rope.git"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

src_install() {
	distutils_src_install
	docinto docs
	dodoc docs/*.txt
}

src_test() {
	PYTHONPATH="." ${python} ropetest/__init__.py
}
