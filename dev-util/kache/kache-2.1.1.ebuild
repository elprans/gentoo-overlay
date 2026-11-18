# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Registry crates are bundled locally with pycargoebuild from Cargo.lock.
CRATES="
"

RUST_MIN_VER="1.95.0"

inherit cargo shell-completion

DESCRIPTION="Compiler cache for Rust, C/C++ and CUDA with local and remote stores"
HOMEPAGE="
	https://kunobi.ninja/docs/kache
	https://github.com/kunobi-ninja/kache
"
SRC_URI="
	https://github.com/kunobi-ninja/kache/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/elprans/gentoo-overlay/releases/download/${P}/${P}-deps.tar.xz
"

LICENSE="Apache-2.0"
# Dependent crate licenses
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD CC0-1.0
	CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 Unicode-DFS-2016
	WTFPL-2 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

QA_FLAGS_IGNORED="
	usr/bin/kache usr/bin/kache-engine
	usr/bin/kache-cl usr/bin/kache-clang-cl
"

PATCHES=(
	# Upstream race: this test does not hold the lock that serializes
	# environment changes, so a parallel test can re-key its probe memo.
	"${FILESDIR}"/${P}-rustdoc-probe-test-env-lock.patch
	# Opt-in [cache] store_compression: compress each fresh output through
	# Btrfs before the store reflinks it, so the build tree and the store
	# share compressed extents instead of uncompressed ones.
	"${FILESDIR}"/${P}-store-compression.patch
)

# Names linked by upstream's canonical shim farm (kache_shims::farm::SHIM_NAMES).
KACHE_SHIMS=( cc c++ gcc g++ clang clang++ cargo rustdoc )

src_prepare() {
	default
	# Upstream denies every rustc warning, so new lints in a newer compiler
	# would fail the build.
	sed -i '/^\[lints\.rust\]/,/^\[/{/^warnings = "deny"$/d}' Cargo.toml || die
	grep -q '^warnings = "deny"$' Cargo.toml && die "warning denial was not removed"
}

src_test() {
	# Run the unit tests. The integration tests drive real Cargo builds
	# through a background daemon; under Portage's sandbox several fail
	# intermittently on timing, although they pass in a normal environment.
	cargo_src_test --workspace --lib --bins
}

src_install() {
	cargo_src_install

	local kache="${ED}/usr/bin/kache" shell
	for shell in bash fish zsh; do
		"${kache}" completions "${shell}" > "kache.${shell}" || die
	done
	newbashcomp kache.bash kache
	dofishcomp kache.fish
	newzshcomp kache.zsh _kache

	# Compiler-name farm, like ccache's: /usr/lib/kache precedes the real
	# compilers in PATH to route them through kache. The marker tells kache to
	# skip this directory when it looks for the real compiler.
	local name
	for name in "${KACHE_SHIMS[@]}"; do
		dosym -r /usr/bin/kache "/usr/lib/kache/${name}"
	done
	: > "${ED}/usr/lib/kache/.kache-shims" || die
	# env-update joins PATH entries in file-name order; sorting before
	# 50baselayout places the shims ahead of /usr/bin for every login. ROOTPATH
	# is left alone, so root shells bypass kache.
	newenvd - 10kache <<< 'PATH="/usr/lib/kache"'

	einstalldocs
}

pkg_postinst() {
	elog "/etc/env.d/10kache puts the shim directory ahead of the compilers in"
	elog "every login PATH; run 'env-update' and log in again to apply it."
	elog "Run 'kache init' as each user to configure Cargo's compiler wrapper"
	elog "and the systemd user service; 'kache init --shims /usr/lib/kache'"
	elog "reuses this package's shim directory, and"
	elog "'kache doctor --probe' checks compile, store and restore locally."
	elog
	elog "The store reflinks compiler outputs, so a compressed store directory"
	elog "alone does not compress them. On Btrfs, set in ~/.config/kache/config.toml:"
	elog "  [cache]"
	elog "  store_compression = \"zstd\"   # or zlib, lzo"
	elog "  store_compression_level = 3   # zstd -15..15, zlib 1..9"
	elog "to compress each output before it is stored and shared."
}
