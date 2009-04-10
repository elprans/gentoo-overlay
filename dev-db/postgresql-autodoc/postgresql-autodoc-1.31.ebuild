# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools

MY_PN="${PN/-/_}"

DESCRIPTION="Automatic schema documenter for PostgreSQL"
HOMEPAGE="http://www.rbt.ca/autodoc/"
SRC_URI="http://www.rbt.ca/autodoc/binaries/${MY_PN}-${PV}.tar.gz"

RESTRICT="nomirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="dev-perl/DBD-Pg
        dev-perl/HTML-Template"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}"

function src_prepare() {
	epatch "${FILESDIR}/destdir.patch"
	eautoreconf
}

function src_configure() {
	econf || die "econf failed"
}

function src_compile() {
	emake || die "emake failed"
}

function src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
