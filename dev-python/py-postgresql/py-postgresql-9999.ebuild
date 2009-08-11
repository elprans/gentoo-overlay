# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/flup/flup-1.0.1.ebuild,v 1.1 2008/12/07 00:10:59 patrick Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"
NEED_PYTHON="3.0"

inherit distutils git

KEYWORDS="amd64 ~ia64 ~ppc ~ppc64 x86"

DESCRIPTION="PostgreSQL connector for Python"
HOMEPAGE="http://python.projects.postgresql.org/"
#SRC_URI="http://python.projects.postgresql.org/files/${PN}-${ORIG_PV}.tar.gz"
EGIT_REPO_URI="git://github.com/jwp/py-postgresql.git"
LICENSE="BSD"
SLOT="0"
IUSE=""

DEPEND="dev-db/postgresql-base"
RDEPEND="${DEPEND}"

RESTRICT_PYTHON_ABIS="2*"
