# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DEPEND=""
PDEPEND="app-portage/findcruft-config"
DESCRIPTION="A library with useful code for bash scripting"
HOMEPAGE="gentoo.coderazor.org/bashlib"
IUSE=""
KEYWORDS="x86 amd64"
LICENSE="GPL-2"
RESTRICT="nomirror"
SLOT="0"
SRC_URI="http://gentoo.coderazor.org/${P}.tar.bz2"

src_install() {
	exeinto /usr/$(get_libdir)/misc
	newexe bashlib.bash bashlib.bash || die
}

