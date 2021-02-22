# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="Intel Thunderbolt Utils"
HOMEPAGE="https://github.com/01org/thunderbolt-software-user-space"
SRC_URI=""
EGIT_REPO_URI="https://github.com/01org/thunderbolt-software-user-space.git"
EGIT_COMMIT="1797ab5a4f9bb3a10efa217d6141dd86ce332809"
EGIT_BRANCH="fwupdate"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
    >=dev-libs/dbus-c++-0.5.0
	>=dev-libs/libnl-3.2.21
"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i /post_install_script.cmake/d "${S}/ThunderboltService/Linux/CMakeLists.txt" || die
	BUILD_DIR="${WORKDIR}/${P}_build_thunderboltd" CMAKE_USE_DIR="${S}/ThunderboltService/Linux" cmake-utils_src_prepare
	BUILD_DIR="${WORKDIR}/${P}_build_libtbtfwu" CMAKE_USE_DIR="${S}/fwupdate/libtbtfwu" cmake-utils_src_prepare
	BUILD_DIR="${WORKDIR}/${P}_build_tbtfwucli" CMAKE_USE_DIR="${S}/fwupdate/tbtfwucli" cmake-utils_src_prepare
}

src_configure() {
	BUILD_DIR="${WORKDIR}/${P}_build_thunderboltd" CMAKE_USE_DIR="${S}/ThunderboltService/Linux" cmake-utils_src_configure
	BUILD_DIR="${WORKDIR}/${P}_build_libtbtfwu" CMAKE_USE_DIR="${S}/fwupdate/libtbtfwu" cmake-utils_src_configure
	BUILD_DIR="${WORKDIR}/${P}_build_tbtfwucli" CMAKE_USE_DIR="${S}/fwupdate/tbtfwucli" cmake-utils_src_configure
}

src_compile() {
	BUILD_DIR="${WORKDIR}/${P}_build_thunderboltd" CMAKE_USE_DIR="${S}/ThunderboltService/Linux" cmake-utils_src_compile
	BUILD_DIR="${WORKDIR}/${P}_build_libtbtfwu" CMAKE_USE_DIR="${S}/fwupdate/libtbtfwu" cmake-utils_src_compile
	BUILD_DIR="${WORKDIR}/${P}_build_tbtfwucli" CMAKE_USE_DIR="${S}/fwupdate/tbtfwucli" cmake-utils_src_compile
}

src_install() {
	BUILD_DIR="${WORKDIR}/${P}_build_thunderboltd" CMAKE_USE_DIR="${S}/ThunderboltService/Linux" cmake-utils_src_install
	BUILD_DIR="${WORKDIR}/${P}_build_libtbtfwu" CMAKE_USE_DIR="${S}/fwupdate/libtbtfwu" cmake-utils_src_install
	BUILD_DIR="${WORKDIR}/${P}_build_tbtfwucli" CMAKE_USE_DIR="${S}/fwupdate/tbtfwucli" cmake-utils_src_install
}
