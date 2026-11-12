# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit python-single-r1

DESCRIPTION="Show Git branches sorted by last commit date, marking merged ones"
HOMEPAGE="https://github.com/wolever/git-blast"
# A local rewrite of upstream 0.4 with aligned columns, commit subjects, and
# `git blast clear`, shipped in files/.
S="${WORKDIR}"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-vcs/git
"

src_install() {
	python_newscript "${FILESDIR}"/git-blast git-blast
}
