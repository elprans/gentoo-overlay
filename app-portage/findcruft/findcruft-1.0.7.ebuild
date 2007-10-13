# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DEPEND=""
PDEPEND="app-portage/findcruft-config"
DESCRIPTION="Yet another script to find obsolete files"
HOMEPAGE="http://forums.gentoo.org/viewtopic.php?t=254197"
IUSE=""
KEYWORDS="x86 amd64"
LICENSE="GPL-2"
RESTRICT="nomirror"
SLOT="0"
SRC_URI="http://gentoo.coderazor.org/${P}.tar.bz2"

src_install() {
	dobin findcruft
	dodoc LICENSE
}

pkg_postinst() {
	einfo "Please check the files findcruft reports as cruft carefully"
	einfo "before deleting them! There may be false positives!"
}
