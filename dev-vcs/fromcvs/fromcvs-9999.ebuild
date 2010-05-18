# Copyright 2000-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#mercurial after ruby!
inherit ruby mercurial multilib

DESCRIPTION="fromcvs converts cvs to git and hg"
HOMEPAGE="http://ww2.fs.ei.tum.de/~corecode/hg/fromcvs"
SRC_URI=""
EHG_REPO_URI="http://ww2.fs.ei.tum.de/~corecode/hg/fromcvs"

LICENSE="donation"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="dev-ruby/rcsparse dev-ruby/rbtree >=dev-vcs/git-1.5"

S="${WORKDIR}/${PN}"

src_install() {
	ruby_src_install

	make_script togit
	make_script tohg
}

make_script() {
	echo "ruby /usr/$(get_libdir)/ruby/site_ruby/$1.rb \$@" > $1
	dobin $1
}
