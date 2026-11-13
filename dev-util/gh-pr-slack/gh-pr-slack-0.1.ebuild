# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit python-single-r1

DESCRIPTION="GitHub CLI extension copying a rich PR summary and opening its Slack channel"
HOMEPAGE="https://github.com/elprans/gentoo-overlay"
# A local extension, ported to the devm guest and shipped in
# files/: devm's `pbcopy --html` and `xdg-open` reach the Mac's clipboard and
# Slack Desktop. devm links /usr/share/gh/extensions into the user's gh.
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

RDEPEND="
	${PYTHON_DEPS}
	dev-util/github-cli
	dev-vcs/git
"
BDEPEND="test? ( ${PYTHON_DEPS} )"

src_unpack() {
	cp "${FILESDIR}"/{gh-pr-slack,pr_slack.py,test_pr_slack.py} "${S}"/ || die
}

src_test() {
	"${EPYTHON}" -m unittest -v test_pr_slack || die
}

src_install() {
	dodoc "${FILESDIR}"/LICENSE
	python_domodule pr_slack.py
	exeinto /usr/share/gh/extensions/gh-pr-slack
	doexe gh-pr-slack
	python_fix_shebang "${ED}"/usr/share/gh/extensions/gh-pr-slack/gh-pr-slack
}
