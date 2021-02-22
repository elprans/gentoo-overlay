# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils git-r3 linux-info udev

DESCRIPTION="Collection of HID++ tools"
HOMEPAGE="https://github.com/PixlOne/hidpp"
SRC_URI=""
EGIT_REPO_URI="https://github.com/PixlOne/hidpp.git"
EGIT_REPO_COMMIT="8fa6d2b7ded97d4a1aebc7c989d889ebc9205800"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	>=dev-libs/tinyxml2-7.1.0:=
	virtual/libudev:=
"

PATCHES=(
	"${FILESDIR}/0001-Install-paths.patch"
)

CONFIG_CHECK="~HIDRAW"
ERROR_HIDRAW="You must enable HIDRAW in your kernel to continue"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_UDEVRULESDIR="$(get_udevdir)"/rules.d
		-DINSTALL_UDEV_RULES=ON
	)
	cmake-utils_src_configure
}
