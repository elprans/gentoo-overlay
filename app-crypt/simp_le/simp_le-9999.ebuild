# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_4,3_5} )

EGIT_REPO_URI="https://github.com/kuba/simp_le.git"

inherit git-r3 distutils-r1

DESCRIPTION="Simple Let's Encrypt client"
HOMEPAGE="https://github.com/kuba/simp_le"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="test"

RDEPEND="=app-crypt/acme-0.1.0[${PYTHON_USEDEP}]
	>=dev-python/cryptography-0.7[${PYTHON_USEDEP}]
	dev-python/mock[${PYTHON_USEDEP}]
	>=dev-python/pyopenssl-0.15[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]"
DEPEND="test? ( ${RDEPEND}
	dev-python/pep8[${PYTHON_USEDEP}] 
	dev-python/pylint[${PYTHON_USEDEP}] )
	dev-python/setuptools[${PYTHON_USEDEP}]"

python_test() {
	simp_le --test || die
}
