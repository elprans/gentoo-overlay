# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/psycopg/psycopg-2.0.8.ebuild,v 1.1 2008/10/15 21:17:57 caleb Exp $
EAPI="2"

NEED_PYTHON=2.4

inherit eutils distutils bzr

MY_P=${PN}2-${PV}

SLOT="2:${PYTHON_SLOT_VERSION}"

DESCRIPTION="PostgreSQL database adapter for Python."
#SRC_URI="http://initd.org/pub/software/psycopg/${MY_P}.tar.gz"
EBZR_REPO_URI="http://initd.org/bazaar/psycopg/psycopg2/"
HOMEPAGE="http://initd.org/projects/psycopg2"

KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
LICENSE="GPL-2"
IUSE="debug doc examples mxdatetime"

DEPEND="virtual/postgresql-base
	mxdatetime? ( dev-python/egenix-mx-base )"
RDEPEND="${DEPEND}"

PYTHON_MODNAME=${PN}2

src_prepare() {
	cd "${S}"

	if use debug; then
		sed -i 's/^\(define=\)/\1PSYCOPG_DEBUG,/' setup.cfg || die "sed failed"
	fi

	if use mxdatetime; then
		sed -i 's/\(use_pydatetime=\)1/\10/' setup.cfg || die "sed failed"
	fi

	epatch "${FILESDIR}/${PN}-fixups.patch"

	if [ "${PYTHON_SLOT_VERSION:0:1}" == "3" ]; then
		epatch "${FILESDIR}/${PN}-py3k.patch"
	fi
}

src_install() {
	DOCS="AUTHORS doc/HACKING doc/SUCCESS doc/TODO doc/async.txt"
	distutils_src_install

	insinto /usr/share/doc/${PF}
	use examples && doins -r examples

	cd doc
	use doc && dohtml -r .
}
