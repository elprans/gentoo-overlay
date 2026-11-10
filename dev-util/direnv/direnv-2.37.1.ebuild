# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Unclutter your .profile with directory-local environment switching"
HOMEPAGE="https://direnv.net/ https://github.com/direnv/direnv"
SRC_URI="https://github.com/direnv/direnv/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/elprans/gentoo-overlay/releases/download/${P}/${P}-deps.tar.xz"

LICENSE="MIT"
# Dependent module licenses
LICENSE+=" BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND=">=dev-lang/go-1.24"

src_compile() {
	ego build -trimpath -ldflags "-s -w" -o direnv
}

src_test() {
	ego test ./...
}

src_install() {
	dobin direnv
	doman man/*.1
	einstalldocs
}
