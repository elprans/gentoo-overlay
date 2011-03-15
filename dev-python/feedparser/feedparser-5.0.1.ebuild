# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/feedparser/feedparser-5.0.1.ebuild,v 1.1 2011/02/22 05:43:01 sping Exp $

EAPI="2"

PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils

DESCRIPTION="Parse RSS and Atom feeds in Python"
HOMEPAGE="http://www.feedparser.org/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.bz2"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="test"

DEPEND=""
RDEPEND=""

PYTHON_MODNAME="feedparser.py"
DOCS=( LICENSE NEWS )

src_prepare() {
	epatch "${FILESDIR}/py3.patch"
}

src_test() {
	testing() {
		cd feedparser || die
		"$(PYTHON)" ${PN}test.py || die
	}
	python_execute_function testing
}
