# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/psycopg/psycopg-2.0.8.ebuild,v 1.1 2008/10/15 21:17:57 caleb Exp $

NEED_PYTHON=2.4

inherit eutils git

DESCRIPTION="A bidirectional Git - Bazaar gateway"
SRC_URI=""
EGIT_REPO_URI="git://github.com/pieter/git-bzr.git"
HOMEPAGE="http://github.com/pieter/git-bzr/"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=dev-util/git-1.6.0
	>=dev-util/bzr-1.9
	>=dev-lang/ruby-1.8.6
	>=dev-util/bzr-fastimport-0.6"
RDEPEND="${DEPEND}"

src_unpack() {
	git_src_unpack
	cd "${S}"
	sed -i -e "s|/opt/local/bin/python2.5|/usr/bin/python|g" \
               -e "s|~/.bazaar/plugins/fastimport/exporters/bzr-fast-export.py|/usr/bin/bzr-fast-export|g" "git-bzr"
}

src_install() {
	exeinto /usr/bin
	doexe git-bzr
	dodoc README
}
