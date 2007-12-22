# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/ecryptfs-utils/ecryptfs-utils-7.ebuild,v 1.3 2007/07/13 05:15:33 mr_bones_ Exp $

DESCRIPTION="eCryptfs userspace utilities"
HOMEPAGE="http://www.ecryptfs.org"
SRC_URI="mirror://sourceforge/ecryptfs/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="sys-apps/keyutils
	dev-libs/libgcrypt"

src_install(){
	emake -j1 DESTDIR=${D} install || die
}