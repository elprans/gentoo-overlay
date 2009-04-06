# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Tool to store the metadata of files,directories,links in a file tree."
HOMEPAGE="http://david.hardeman.nu/software.php"
SRC_URI="http://gentoo.coderazor.org/metastore-20090322.tar.gz"
RESTRICT="nomirror"

#EGIT_REPO_URI="git://git.hardeman.nu/metastore.git"
#EGIT_FETCH_CMD="git clone --bare"

LICENSE="GPL-2"
IUSE=""
KEYWORDS="~x86 ~amd64 ~hppa ~ppc ~sparc"
SLOT="0"
S="${WORKDIR}/${PN}"

src_compile() {
	emake || die "make failed"
}


src_install() {
	emake DESTDIR=${D} install || die "make install failed"
	dodoc README || die "docs failed"
}
