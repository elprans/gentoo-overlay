# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils git-r3

DESCRIPTION="An unofficial userspace driver for HID++ Logitech devices"
HOMEPAGE="https://github.com/PixlOne/logiops"
SRC_URI=""
EGIT_REPO_URI="https://github.com/PixlOne/logiops.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	>=dev-libs/libhidpp-0_pre20191002
	>=dev-libs/libevdev-1.8.0:=
	>=dev-libs/libconfig-1.5:=
	virtual/libudev:=
"
