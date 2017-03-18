# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit autotools eutils multilib

SANE_VER="1.0.22"
SANE="sane-backends-${SANE_VER}"

UPSTREAM_REV="0.2"
UPSTREAM_PV="${PV}-${UPSTREAM_REV}"
UPSTREAM_P="${PN}-${UPSTREAM_PV}"

DESCRIPTION="Canon Sane backend for P-150 scanner"
HOMEPAGE="http://software.canon-europe.com/software/0037654.asp"
SRC_URI="http://files.canon-europe.com/files/soft37654/software/d1024mux.zip
         ftp://ftp.sane-project.org/pub/sane/${SANE}/${SANE}.tar.gz"

LICENSE="GPL-2 CANON"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="
	media-gfx/sane-backends
	>=dev-libs/libusb-0.1.2
"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${UPSTREAM_P}"

src_unpack() {
	default

	pushd "${WORKDIR}" >/dev/null
	mv "${UPSTREAM_PV}/P-150/${PN}-${UPSTREAM_PV}.tar.gz" ./ || die "unpack failed"
	unpack "./${UPSTREAM_P}.tar.gz"
	popd >/dev/null
}

src_prepare() {
	# Copy sane sources

	pushd "${S}" >/dev/null

	mkdir sane \
		&& cp -a "../${SANE}/include" ./sane/ \
		&& cp -a "../${SANE}/sanei" ./sane/ \
		|| die "failed to copy sane sources"

	popd >/dev/null

	epatch "${FILESDIR}/${P}-makefile.patch"

	eautoreconf
}

src_configure() {
	default

	pushd "${WORKDIR}/${SANE}" >/dev/null
	econf
	popd >/dev/null

	cp "${WORKDIR}/${SANE}/include/sane/config.h" "${S}/sane/include/sane/"
}

src_install() {
	emake install DESTDIR="${D}"
	chmod +x "${D}/usr/$(get_libdir)/canondr/canondr_backendp150"
}
