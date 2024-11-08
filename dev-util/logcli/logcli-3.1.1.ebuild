# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="A command-line for loki."
HOMEPAGE="https://grafana.com/loki"
SRC_URI="https://github.com/grafana/loki/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror strip"

S="${WORKDIR}/loki-${PV}"

src_compile() {
	local BUILD_VERSION="${PV}"
	local BUILD_REVISION="${PV}"
	local BUILD_USER="${P}"
	local BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

	local VPREFIX="github.com/grafana/${PN}/vendor/github.com/prometheus/common/version"

	local EGO_LDFLAGS="-s -w -X ${VPREFIX}.Version=${BUILD_VERSION} -X ${VPREFIX}.Revision=${BUILD_REVISION} -X ${VPREFIX}.BuildUser=${BUILD_USER} -X ${VPREFIX}.BuildDate=${BUILD_DATE}"

	einfo "Building cmd/logcli/logcli..."
	CGO_ENABLED=0 ego build -ldflags "-extldflags \"-static\" ${EGO_LDFLAGS}" -tags netgo -mod vendor -o cmd/logcli/logcli ./cmd/logcli || die
}

src_install() {
	dobin "${S}/cmd/logcli/logcli"
}
