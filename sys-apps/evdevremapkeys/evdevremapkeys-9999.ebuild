# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python{3_5,3_6} )
EGIT_REPO_URI="https://github.com/elprans/evdevremapkeys.git"

inherit distutils-r1 eutils git-r3 systemd

DESCRIPTION="Daemon to remap events on linux input devices"
HOMEPAGE="https://github.com/elprans/evdevremapkeys.git"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"

RDEPEND="
	>=dev-python/python-daemon-2.1.1[$PYTHON_USEDEP]
	>=dev-python/python-evdev-0.7.0[$PYTHON_USEDEP]
	>=dev-python/pyinotify-0.9.0[$PYTHON_USEDEP]
	>=dev-python/pyxdg-0.25[$PYTHON_USEDEP]
	>=dev-python/pyyaml-3.13[$PYTHON_USEDEP]
"

src_install() {
	distutils-r1_src_install
	systemd_dounit "${S}/${PN}.service"
	dodir "/etc/"
	echo "devices: []" >> "${D}/etc/${PN}.yml" || die
}
