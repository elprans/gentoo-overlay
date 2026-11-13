# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Vercel CLI, the upstream native binary build"
HOMEPAGE="https://vercel.com/docs/cli https://github.com/vercel/vercel"
SRC_URI="
	amd64? ( https://registry.npmjs.org/@vercel/vc-native-linux-x64/-/vc-native-linux-x64-${PV}.tgz -> ${P}-amd64.tgz )
	arm64? ( https://registry.npmjs.org/@vercel/vc-native-linux-arm64/-/vc-native-linux-arm64-${PV}.tgz -> ${P}-arm64.tgz )
"
S="${WORKDIR}/package"

# The binary embeds Node.js and the CLI's bundled npm dependencies.
LICENSE="Apache-2.0 MIT BSD ISC"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# A single executable application: stripping drops the embedded CLI.
RESTRICT="strip"

RDEPEND="sys-devel/gcc:*"

QA_PREBUILT="opt/vercel/bin/vercel"

src_compile() {
	# The binary extracts native addons, such as the OS keyring binding, into
	# a cache before loading them. Extract them now, so they are installed
	# root-owned and the launcher points the user's cache at them.
	env -i PATH="${PATH}" HOME="${T}/home" \
		PKG_NATIVE_CACHE_PATH="${T}/native" \
		VERCEL_TOKEN_STORAGE=keyring VERCEL_TELEMETRY_DISABLED=1 \
		./bin/vercel whoami >/dev/null 2>&1
	[[ -n $(find "${T}/native/pkg" -name '*.node' 2>/dev/null) ]] ||
		die "the binary extracted no native addons"
}

src_install() {
	exeinto /opt/vercel/bin
	doexe bin/vercel
	insinto /opt/vercel/native
	doins -r "${T}/native/pkg"
	newbin "${FILESDIR}"/vercel-launcher vercel
}
