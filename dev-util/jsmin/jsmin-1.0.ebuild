# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/xmlindent/xmlindent-0.2.17.ebuild,v 1.3 2007/07/12 01:05:42 mr_bones_ Exp $

inherit eutils
DESCRIPTION="JSMIN, The JavaScript Minifier"
HOMEPAGE="http://www.crockford.com/javascript/jsmin.html"
SRC_URI="http://gentoo.coderazor.org/jsmin-${PV}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE=""

src_compile() {
	emake || die "emake failed"
}

src_install() {
	dobin jsmin
}
