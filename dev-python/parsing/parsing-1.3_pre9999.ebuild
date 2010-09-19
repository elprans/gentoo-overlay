# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/flup/flup-1.0.1.ebuild,v 1.1 2008/12/07 00:10:59 patrick Exp $

EAPI="3"
SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND="3"

EGIT_REPO_URI="git://labs.sprymix.com/Parsing.py.git"

inherit python git

KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86"

DESCRIPTION="Python parser generator module"
HOMEPAGE="http://www.canonware.com/Parsing/"
LICENSE="BSD"
SLOT="0"
IUSE=""

RESTRICT_PYTHON_ABIS="2*"

pkg_setup() {
	python_pkg_setup
}

_install() {
	local ld="${D}/$(python_get_sitedir)"
	mkdir -p "${ld}" || die "installation failed"
	cp "${S}/Parsing.py" "${ld}" || die "installation failed"
}

src_install() {
	python_execute_function -q _install
}
