# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib-minimal

DESCRIPTION="Support for hybrid VPx codec in Intel GPUs"
HOMEPAGE="https://github.com/intel/intel-hybrid-driver"
SRC_URI="https://github.com/intel/intel-hybrid-driver/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="wayland X"

RDEPEND="
	>=media-libs/cmrt-1.0[${MULTILIB_USEDEP}]
	>=x11-libs/libdrm-2.4.52[video_cards_intel,${MULTILIB_USEDEP}]
	>=x11-libs/libva-2.4.0:=[X?,wayland?,drm,${MULTILIB_USEDEP}]
	wayland? (
		>=dev-libs/wayland-1.11[${MULTILIB_USEDEP}]
		>=media-libs/mesa-9.1.6[egl,${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"
S="${WORKDIR}/intel-hybrid-driver-${PV}"
PATCHES=(
	"${FILESDIR}/gcc-10.patch"
	"${FILESDIR}/libva-2.patch"
)

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	local myconf=(
		$(use_enable wayland)
		$(use_enable X x11)
	)
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_install_all() {
	find "${D}" -name "*.la" -delete || die
}
