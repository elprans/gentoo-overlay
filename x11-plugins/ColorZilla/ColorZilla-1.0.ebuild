# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib autotools

DESCRIPTION="Advanced Eyedropper, ColorPicker, Page Zoomer and other colorful goodies for Mozilla Firefox"
HOMEPAGE="http://www.iosart.com/firefox/colorzilla/"
XPI="${P/-/_}"
COMPONENT_VER="1.0"
SRC_URI="http://www.iosart.com/firefox/colorzilla/${XPI}.xpi 
		http://gentoo.coderazor.org/colorzilla-${COMPONENT_VER}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND="|| (
	>=www-client/mozilla-firefox-1.5.0.7
)"
DEPEND="${RDEPEND}"

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${XPI}.xpi"
	cd ${S}
	unpack "colorzilla-${COMPONENT_VER}.tar.bz2"
}

src_compile() {
	cd "${S}/colorzilla-${COMPONENT_VER}"
	AT_M4DIR=m4	eautoreconf || die
	econf || die
	emake || die
}

src_install() {
	cp "${S}/colorzilla-${COMPONENT_VER}/src/mozIColorZilla.xpt" \
		"${S}/${XPI}/components/ColorZilla.xpt"

	cp "${S}/colorzilla-${COMPONENT_VER}/src/.libs/ColorZilla.so" \
		"${S}/${XPI}/components/ColorZilla.dll"

	rm "${S}/${XPI}/components/ColorZilla.dll.linux"

	cp "${FILESDIR}/chrome.manifest-${PV}" \
		"${S}/${XPI}/chrome.manifest"

	declare MOZILLA_FIVE_HOME
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-firefox"
	xpi_install "${S}"/"${XPI}"
}
