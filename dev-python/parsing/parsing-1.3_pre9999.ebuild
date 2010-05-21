# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/flup/flup-1.0.1.ebuild,v 1.1 2008/12/07 00:10:59 patrick Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"
NEED_PYTHON="3.0"

EGIT_REPO_URI="git://labs.sprymix.com/Parsing.py.git"

inherit python git

KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86"

DESCRIPTION="Python parser generator module"
HOMEPAGE="http://www.canonware.com/Parsing/"
LICENSE="BSD"
SLOT="0"
IUSE=""

RESTRICT_PYTHON_ABIS="2*"

src_install() {
	local PYTHON_ABI

	validate_PYTHON_ABIS
	for PYTHON_ABI in ${PYTHON_ABIS}; do
		local ld="${D}/$(python_get_sitedir)"
		mkdir -p "${ld}" || die "installation failed"
		cp "${S}/Parsing.py" "${ld}" || die "installation failed"
	done
}
