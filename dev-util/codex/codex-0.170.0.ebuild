# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Based on GURU's Codex recipe. The crate bundle is generated locally with
# pycargoebuild from the patched checkout's Cargo.lock.

CRATES="
"

declare -A GIT_CRATES=(
	[crossterm]='https://github.com/openai-oss-forks/crossterm;ed1cdab335221515706178d68495bba2aed1924f;crossterm-%commit%'
	[h3-quinn]='https://github.com/hyperium/h3;e07e69412876f7e26f026bd75a48b2704d8c8283;h3-%commit%/h3-quinn'
	[h3]='https://github.com/hyperium/h3;e07e69412876f7e26f026bd75a48b2704d8c8283;h3-%commit%/h3'
	[mxc-sdk]='https://github.com/microsoft/mxc;b21120168d70befe12356411423266bfef168446;mxc-%commit%/src/mxc-sdk'
	[nucleo-matcher]='https://github.com/helix-editor/nucleo;4253de9faabb4e5c6d81d946a5e35a90f87347ee;nucleo-%commit%/matcher'
	[nucleo]='https://github.com/helix-editor/nucleo;4253de9faabb4e5c6d81d946a5e35a90f87347ee;nucleo-%commit%'
	[rmcp-macros]='https://github.com/modelcontextprotocol/rust-sdk;98a54789b80110ad210495c4ad845c89e1980471;rust-sdk-%commit%/crates/rmcp-macros'
	[rmcp]='https://github.com/modelcontextprotocol/rust-sdk;98a54789b80110ad210495c4ad845c89e1980471;rust-sdk-%commit%/crates/rmcp'
	[runfiles]='https://github.com/dzbarsky/rules_rust;b56cbaa8465e74127f1ea216f813cd377295ad81;rules_rust-%commit%/rust/runfiles'
	[sqlx-core]='https://github.com/transact-rs/sqlx;10462fa4414c6c7f1ed1d39bb31678e3b726878c;sqlx-%commit%/sqlx-core'
	[sqlx-sqlite]='https://github.com/transact-rs/sqlx;10462fa4414c6c7f1ed1d39bb31678e3b726878c;sqlx-%commit%/sqlx-sqlite'
	[tokio-tungstenite]='https://github.com/openai-oss-forks/tokio-tungstenite;7447c427513cfe685f236e1ac0513c4ea3dd9c0b;tokio-tungstenite-%commit%'
	[tungstenite]='https://github.com/openai-oss-forks/tungstenite-rs;bc589d684755a8c02da0fc7e58d0861cbfc306f1;tungstenite-rs-%commit%'
	[v8]='https://github.com/openai-oss-forks/rusty_v8;90a65f887a0c0f048f3784afbcb320b373c8a2e0;rusty_v8-%commit%'
)

RUST_MIN_VER="1.95.0"

# python3 .github/scripts/rusty_v8_bazel.py resolved-v8-crate-version
RUSTY_V8_TAG="152.2.0"

inherit cargo check-reqs toolchain-funcs

CHECKREQS_MEMORY="15G"
CHECKREQS_DISK_BUILD="20G"

DESCRIPTION="Codex CLI - OpenAI's AI-powered coding agent"
HOMEPAGE="https://github.com/openai/codex"

SRC_URI="
	https://github.com/openai/${PN}/archive/rust-v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
	https://github.com/elprans/gentoo-overlay/releases/download/${P}/${P}-deps.tar.xz
	amd64? (
		https://github.com/openai/codex/releases/download/rusty-v8-v${RUSTY_V8_TAG}/librusty_v8_release_x86_64-unknown-linux-musl.a.gz
			-> rusty_v8_${RUSTY_V8_TAG}_librusty_v8_release_x86_64-unknown-linux-musl.a.gz
		https://github.com/openai/codex/releases/download/rusty-v8-v${RUSTY_V8_TAG}/src_binding_release_x86_64-unknown-linux-musl.rs
			-> rusty_v8_${RUSTY_V8_TAG}_src_binding_release_x86_64-unknown-linux-musl.rs
	)
	arm64? (
		https://github.com/openai/codex/releases/download/rusty-v8-v${RUSTY_V8_TAG}/librusty_v8_release_aarch64-unknown-linux-musl.a.gz
			-> rusty_v8_${RUSTY_V8_TAG}_librusty_v8_release_aarch64-unknown-linux-musl.a.gz
		https://github.com/openai/codex/releases/download/rusty-v8-v${RUSTY_V8_TAG}/src_binding_release_aarch64-unknown-linux-musl.rs
			-> rusty_v8_${RUSTY_V8_TAG}_src_binding_release_aarch64-unknown-linux-musl.rs
	)
	${CARGO_CRATE_URIS}
"

S="${WORKDIR}/${PN}-rust-v${PV}/codex-rs"

LICENSE="Apache-2.0"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC0-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0
	Unicode-DFS-2016 WTFPL-2 ZLIB BZIP2
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
# Tests need GStreamer 1.28 and the upstream voice runtime fixtures
RESTRICT="test"

DEPEND="dev-libs/openssl:="
RDEPEND="${DEPEND}
	>=sys-apps/bubblewrap-0.11.2
	sys-apps/ripgrep
"
BDEPEND="
	dev-vcs/git
	virtual/pkgconfig
"

# rust does not use *FLAGS from make.conf, silence portage warning
QA_FLAGS_IGNORED="usr/lib/${PN}/bin/*"

PATCHES=(
	"${FILESDIR}/${P}-keyring-provider-auth-fallback.patch"
	"${FILESDIR}/${P}-provider-reported-thread-cost.patch"
	"${FILESDIR}/${P}-sandbox-unix-sockets.patch"
	"${FILESDIR}/${P}-sync-followup-questions.patch"
	"${FILESDIR}/${P}-system-ripgrep-daemon-package.patch"
	"${FILESDIR}/${P}-use-shipped-app-server.patch"
)

pkg_pretend() {
	check-reqs_pkg_pretend
}

pkg_setup() {
	check-reqs_pkg_setup
	rust_pkg_setup
	if tc-is-lto; then
		export CARGO_PROFILE_RELEASE_LTO=thin
	else
		export CARGO_PROFILE_RELEASE_LTO=false
	fi
}

gen_git_crate_dir() {
	# https://github.com/gentoo/gentoo/blob/b09dd88412fe2d5eee5a8891e08bfa2d67848da3/eclass/cargo.eclass#L442
	IFS=';' read -r crate_uri commit crate_dir <<<"${GIT_CRATES[$1]}"
	echo "${WORKDIR}/${crate_dir//%commit%/${commit}}"
}

src_prepare() {
	default

	# Git binary deltas contain the generated stable and experimental schemas.
	git apply --binary -p1 "${FILESDIR}/${P}-schema-exports.gitpatch" || die

	# Fix tokio-tungstenite's git dependency on tungstenite
	sed -i '/^\[dependencies\.tungstenite\]/,/^$/{
		s|git = "https://github.com/openai-oss-forks/tungstenite-rs"|path = "'"$(gen_git_crate_dir tungstenite)"'"|
		/^rev = /d
	}' "$(gen_git_crate_dir tokio-tungstenite)/Cargo.toml" || die

	# Remove the [patch.crates-io] section and add path-based patches
	sed -i '/^\[patch\.crates-io\]/,/^$/d' "${S}/Cargo.toml" || die
	sed -i '/^\[patch\."ssh:\/\/git@github\.com/,/^$/d' "${S}/Cargo.toml" || die

	# Add new patch section with local paths
	cat >> "${S}/Cargo.toml" <<-EOF || die

	[patch.crates-io]
	crossterm = { path = "$(gen_git_crate_dir crossterm)" }
	sqlx-core = { path = "$(gen_git_crate_dir sqlx-core)" }
	sqlx-sqlite = { path = "$(gen_git_crate_dir sqlx-sqlite)" }
	tokio-tungstenite = { path = "$(gen_git_crate_dir tokio-tungstenite)" }
	tungstenite = { path = "$(gen_git_crate_dir tungstenite)" }
	v8 = { path = "$(gen_git_crate_dir v8)" }
	EOF
}

src_compile() {
	local rusty_v8_triple
	use amd64 && rusty_v8_triple=x86_64-unknown-linux-musl
	use arm64 && rusty_v8_triple=aarch64-unknown-linux-musl

	# codex-core trait resolution overflows rustc's default 8MiB stack
	export RUST_MIN_STACK=16777216

	RUSTY_V8_ARCHIVE="${DISTDIR}/rusty_v8_${RUSTY_V8_TAG}_librusty_v8_release_${rusty_v8_triple}.a.gz" \
	RUSTY_V8_SRC_BINDING_PATH="${DISTDIR}/rusty_v8_${RUSTY_V8_TAG}_src_binding_release_${rusty_v8_triple}.rs" \
		cargo_src_compile \
			--bin codex \
			--bin codex-code-mode-host
}

src_install() {
	local pkgdir="/usr/lib/${PN}"
	local pkg_target
	case ${ARCH} in
		amd64) pkg_target="x86_64-unknown-linux-gnu" ;;
		arm64) pkg_target="aarch64-unknown-linux-gnu" ;;
	esac

	exeinto "${pkgdir}"/bin
	doexe "$(cargo_target_dir)/codex" "$(cargo_target_dir)/codex-code-mode-host"

	# The app-server daemon installs the CLI from this layout, see
	# https://github.com/openai/codex/issues/48050
	cat > "${T}"/codex-package.json <<-EOF || die
		{
		  "layoutVersion": 1,
		  "version": "${PV}",
		  "target": "${pkg_target}",
		  "variant": "codex",
		  "entrypoint": "bin/codex",
		  "resourcesDir": "codex-resources",
		  "pathDir": "codex-path"
		}
	EOF
	insinto "${pkgdir}"
	doins "${T}"/codex-package.json

	# The layout requires both files, they resolve to the system programs
	printf '#!/bin/sh\nexec %s/usr/bin/rg "$@"\n' "${EPREFIX}" > "${T}"/rg || die
	printf '#!/bin/sh\nexec %s/usr/bin/bwrap "$@"\n' "${EPREFIX}" > "${T}"/bwrap || die
	exeinto "${pkgdir}"/codex-path
	doexe "${T}"/rg
	exeinto "${pkgdir}"/codex-resources
	doexe "${T}"/bwrap

	dosym ../lib/"${PN}"/bin/codex /usr/bin/"${PN}"
	dosym ../lib/"${PN}"/bin/codex-code-mode-host /usr/bin/codex-code-mode-host

	einstalldocs
}
