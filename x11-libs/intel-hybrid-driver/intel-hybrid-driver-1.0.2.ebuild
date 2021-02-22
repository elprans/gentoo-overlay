# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools eutils

DESCRIPTION="Support for hybrid VPx codec in Intel GPUs"
HOMEPAGE="https://github.com/intel/intel-hybrid-driver"
SRC_URI="https://github.com/intel/intel-hybrid-driver/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="wayland X"

RDEPEND="x11-libs/libva
	x11-libs/libdrm
	media-libs/cmrt"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch "${PATCHES[@]}"
	eautoreconf
}
src_configure() {
	local myconf=(
		$(use_enable wayland)
		$(use_enable X x11)
	)
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_install_all() {
	find "${D}" -name "*.la" -delete || die
}
