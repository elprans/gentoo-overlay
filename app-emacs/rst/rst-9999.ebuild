# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/rst/rst-0.4-r1.ebuild,v 1.8 2008/09/20 17:55:52 vapier Exp $

inherit elisp eutils subversion

DESCRIPTION="ReStructuredText support for Emacs"
HOMEPAGE="http://www.emacswiki.org/cgi-bin/wiki/reStructuredText"
SRC_URI=""
ESVN_REPO_URI="http://svn.berlios.de/svnroot/repos/docutils/trunk/docutils/tools/editors/emacs/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""

S="${WORKDIR}/emacs"
SITEFILE=51${PN}-gentoo.el
DOCS="README.txt"

src_unpack() {
	subversion_src_unpack
	cd "${S}"
}
