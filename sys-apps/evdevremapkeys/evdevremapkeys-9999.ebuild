# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9..12} )
DISTUTILS_USE_PEP517="setuptools"
EGIT_REPO_URI="https://github.com/elprans/evdevremapkeys.git"

inherit distutils-r1 git-r3 systemd

DESCRIPTION="Daemon to remap events on linux input devices"
HOMEPAGE="https://github.com/elprans/evdevremapkeys.git"

LICENSE="MIT"
SLOT="0"

RDEPEND="
	>=dev-python/python-evdev-0.7.0[$PYTHON_USEDEP]
	>=dev-python/pyudev-0.22.0[$PYTHON_USEDEP]
	>=dev-python/pyxdg-0.25[$PYTHON_USEDEP]
	>=dev-python/pyyaml-3.13[$PYTHON_USEDEP]
"

src_install() {
	distutils-r1_src_install
	systemd_dounit "${FILESDIR}/${PN}.service"
	dodir "/etc/"
	echo "devices: []" >> "${D}/etc/${PN}.yml" || die
}
