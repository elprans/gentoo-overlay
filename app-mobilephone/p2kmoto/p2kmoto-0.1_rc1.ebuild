# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-mobilephone/moto4lin/moto4lin-0.3.ebuild,v 1.4 2005/10/10 19:23:24 mrness Exp $

inherit eutils

DESCRIPTION="p2kmoto is a library for communicating with supported Motorola P2K phones."
HOMEPAGE="http://moto4lin.sourceforge.net/"
MY_PV=${PV/_rc/-rc}
SRC_URI="mirror://sourceforge/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
S=${S%_rc*}
DEPEND="dev-libs/libusb"

src_unpack() {
	unpack "${A}"
	cd "${S}"
}

src_compile() {
	cd "${S}"
	econf || die "Configure failed."
	emake || die "Make failed."
}

src_install() {
	einstall || die "Install failed."
	dodoc Changelog README
}
