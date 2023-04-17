# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module

DESCRIPTION="The easiest way to access your cloud."
HOMEPAGE="https://docs.commonfate.io/granted/"
SRC_URI="https://github.com/common-fate/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://storage.googleapis.com/ep-overlay-distfiles/${P}-deps.tar.xz"

LICENSE="Apache-2.0 BSD BSD-2 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="test"

DOCS=( README.md )

src_prepare() {
	default
	sed -i -e "|/usr/local/bin|/usr/bin|g" pkg/alias/alias.go
}

src_compile() {
	export CGO_ENABLED=0
	local PKG="github.com/common-fate/granted"
	local BUILD_DATE=$(date -u +"%Y%m%d%H%M")
	local ldflags=(
		"-X ${PKG}/internal/build.ConfigFolderName=.config/granted"
		"-X ${PKG}/internal/build.Version=${PV}"
		"-X ${PKG}/internal/build.Date=${BUILD_DATE}"
		"-X ${PKG}/internal/build.BuiltBy=gentoo"
	)
	ego build -ldflags "${ldflags[*]}" -o ./bin/granted cmd/granted/main.go
	ego build -ldflags "${ldflags[*]}" -o ./bin/assumego cmd/assume/main.go
}

src_install() {
	dobin bin/*
	dobin scripts/assume
	einstalldocs
}
