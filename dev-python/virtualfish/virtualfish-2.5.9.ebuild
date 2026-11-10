# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP517=poetry

inherit distutils-r1 pypi

DESCRIPTION="A Python virtual environment manager for the Fish shell"
HOMEPAGE="https://pypi.python.org/pypi/virtualfish"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/packaging-21.3[$PYTHON_USEDEP]
	>=dev-python/pkgconfig-1.5[$PYTHON_USEDEP]
	>=dev-python/psutil-5.7[$PYTHON_USEDEP]
	>=dev-python/virtualenv-20[$PYTHON_USEDEP]
"
