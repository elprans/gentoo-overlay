# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/qbzr/qbzr-0.9.6.ebuild,v 1.1 2009/01/10 17:04:26 pva Exp $

EAPI="2"

NEED_PYTHON="2.4"

inherit distutils versionator bzr

DESCRIPTION="Bazaar Fast Import Plugin"
HOMEPAGE="https://launchpad.net/bzr-fastimport"
#SRC_URI="http://launchpad.net/bzr-fastimport/trunk/${PV}/+download/${P}.tar.gz"
EBZR_REPO_URI="lp:bzr-fastimport/$(get_version_component_range 1-2)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

DEPEND=">=dev-util/bzr-1.3"

DOCS="COPYING.txt NEWS README.txt"

PYTHON_MODNAME=bzrlib

src_prepare() {
	sed -i -e "s/if __name__ == 'main'/if True/g" setup.py || die "sed failed"
}

src_install() {
	distutils_src_install
	newbin exporters/bzr-fast-export.py bzr-fast-export
}
