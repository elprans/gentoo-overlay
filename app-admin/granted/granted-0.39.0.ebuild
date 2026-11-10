# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module

DESCRIPTION="The easiest way to access your cloud"
HOMEPAGE="https://docs.commonfate.io/granted/ https://github.com/fwdcloudsec/granted"
SRC_URI="https://github.com/fwdcloudsec/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/elprans/gentoo-overlay/releases/download/${P}/${P}-deps.tar.xz"

LICENSE="Apache-2.0 BSD BSD-2 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND=">=dev-lang/go-1.25.7"

RESTRICT="test"

DOCS=( README.md )

src_prepare() {
	default
	sed -i -e "s|/usr/local/bin|/usr/bin|g" pkg/alias/alias.go || die
}

src_compile() {
	export CGO_ENABLED=0
	local PKG="github.com/fwdcloudsec/granted"
	local BUILD_DATE=$(date -u +"%Y%m%d%H%M")
	local ldflags=(
		"-X ${PKG}/internal/build.ConfigFolderName=.config/granted"
		"-X ${PKG}/internal/build.Version=${PV}"
		"-X ${PKG}/internal/build.Date=${BUILD_DATE}"
		"-X ${PKG}/internal/build.BuiltBy=gentoo"
	)
	ego build -ldflags "${ldflags[*]}" -o ./bin/granted ./cmd/granted
}

src_install() {
	dobin bin/*
	dosym granted /usr/bin/assumego
	dobin scripts/assume scripts/assume.fish
	einstalldocs
}
