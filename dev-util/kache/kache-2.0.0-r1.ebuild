# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	aes@0.8.4
	ahash@0.8.12
	aho-corasick@1.1.5
	allocator-api2@0.2.21
	android_system_properties@0.1.6
	annotate-snippets@0.12.17
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.104
	approx@0.5.1
	arraydeque@0.5.1
	arrayvec@0.7.8
	assert_cmd@2.2.2
	async-trait@0.1.92
	asyncband@0.7.3
	atomic-waker@1.1.2
	atomic@0.6.1
	autocfg@1.5.1
	aws-lc-rs@1.18.2
	aws-lc-sys@0.46.0
	axum-core@0.5.6
	axum@0.8.9
	backon@1.6.0
	base16ct@0.2.0
	base16ct@1.0.0
	base64@0.22.1
	base64@0.23.1
	base64ct@1.8.3
	bit-set@0.5.3
	bit-vec@0.6.3
	bitflags@1.3.2
	bitflags@2.13.2
	blake3@1.8.7
	block-buffer@0.10.4
	block-buffer@0.12.1
	block-padding@0.3.3
	bs58@0.5.1
	bstr@1.13.1
	buffa@0.9.2
	bumpalo@3.20.3
	by_address@1.2.1
	bytemuck@1.25.2
	bytes@1.12.1
	bytesize@2.7.0
	castaway@0.2.4
	cbc@0.1.2
	cc@1.9.0
	cfg-if@1.0.5
	cfg_aliases@0.2.2
	chacha20@0.10.2
	chrono@0.4.45
	cipher@0.4.4
	clap@4.6.7
	clap_builder@4.6.7
	clap_complete@4.6.11
	clap_derive@4.6.7
	clap_lex@1.1.1
	cmake@0.1.58
	cmov@0.5.4
	colorchoice@1.0.5
	combine@4.6.9
	compact_str@0.9.1
	const-oid@0.10.2
	const-oid@0.9.6
	const-random-macro@0.1.16
	const-random@0.1.18
	const_format@0.2.36
	const_format_proc_macros@0.2.34
	constant_time_eq@0.4.2
	convert_case@0.10.0
	core-foundation-sys@0.8.7
	core-foundation@0.10.1
	core_detect@1.0.0
	cpubits@0.1.1
	cpufeatures@0.2.17
	cpufeatures@0.3.1
	crc-fast@1.10.0
	critical-section@1.2.0
	crossterm@0.29.0
	crossterm_winapi@0.9.1
	crunchy@0.2.4
	crypto-bigint@0.5.5
	crypto-bigint@0.7.9
	crypto-common@0.1.6
	crypto-common@0.2.2
	csscolorparser@0.6.2
	ctutils@0.4.5
	curve25519-dalek-derive@0.1.1
	curve25519-dalek@4.1.3
	curve25519-dalek@5.0.0
	darling@0.20.11
	darling@0.24.1
	darling_core@0.20.11
	darling_core@0.24.1
	darling_macro@0.20.11
	darling_macro@0.24.1
	defmt-macros@1.2.0
	defmt-parser@1.1.0
	defmt@1.2.0
	deltae@0.3.2
	der@0.7.10
	der@0.8.3
	deranged@0.5.9
	derive_builder@0.20.2
	derive_builder_core@0.20.2
	derive_builder_macro@0.20.2
	derive_more-impl@2.1.1
	derive_more@2.1.1
	difflib@0.4.0
	digest@0.10.7
	digest@0.11.3
	dirs-sys@0.5.0
	dirs@7.0.0
	displaydoc@0.2.7
	dlv-list@0.5.2
	docker_credential@1.4.0
	doctest-file@1.1.1
	document-features@0.2.12
	dunce@1.0.5
	dyn-clone@1.0.20
	ecdsa@0.16.9
	ecdsa@0.17.0
	ed25519-dalek@2.2.0
	ed25519-dalek@3.0.0
	ed25519@2.2.3
	ed25519@3.0.0
	either@1.19.0
	elliptic-curve@0.13.8
	elliptic-curve@0.14.2
	encoding_rs@0.8.42
	encoding_rs_io@0.1.8
	equivalent@1.0.3
	errno@0.3.14
	euclid@0.22.14
	fallible-iterator@0.3.0
	fallible-streaming-iterator@0.1.9
	fancy-regex@0.11.0
	fastrand@2.5.0
	ff@0.13.1
	ff@0.14.0
	fiat-crypto@0.2.9
	fiat-crypto@0.3.0
	filedescriptor@0.8.3
	filetime@0.2.29
	find-msvc-tools@0.1.15
	finl_unicode@1.5.0
	fixedbitset@0.4.2
	float-cmp@0.10.0
	fnv@1.0.7
	foldhash@0.1.5
	foldhash@0.2.0
	form_urlencoded@1.2.2
	fs_extra@1.3.0
	futures-channel@0.3.34
	futures-core@0.3.34
	futures-executor@0.3.34
	futures-io@0.3.34
	futures-macro@0.3.34
	futures-sink@0.3.34
	futures-task@0.3.34
	futures-util@0.3.34
	futures@0.3.34
	generator@0.8.11
	generic-array@0.14.9
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.3
	getset@0.1.7
	glob@0.3.4
	gloo-timers@0.3.0
	granit-parser@0.0.7
	group@0.13.0
	group@0.14.0
	hashbrown@0.12.3
	hashbrown@0.14.5
	hashbrown@0.15.5
	hashbrown@0.16.1
	hashbrown@0.17.1
	hashlink@0.12.2
	heck@0.5.0
	hex@0.4.3
	hmac@0.12.1
	hmac@0.13.0
	home@0.5.12
	http-auth@0.1.10
	http-body-util@0.1.5
	http-body@1.1.0
	http@1.5.0
	httparse@1.10.1
	httpdate@1.0.3
	hybrid-array@0.4.15
	hyper-rustls@0.27.10
	hyper-timeout@0.5.2
	hyper-util@0.1.21
	hyper@1.12.0
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	icu_collections@2.4.0
	icu_locale_core@2.4.0
	icu_normalizer@2.4.0
	icu_normalizer_data@2.4.0
	icu_properties@2.4.0
	icu_properties_data@2.4.0
	icu_provider@2.4.0
	ident_case@1.0.1
	idna@1.1.0
	idna_adapter@1.2.2
	indexmap@1.9.3
	indexmap@2.14.2
	indoc@2.0.8
	inout@0.1.4
	instability@0.3.14
	interprocess@2.4.7
	ipnet@2.12.2
	is-docker@0.2.0
	is-wsl@0.4.0
	is_terminal_polyfill@1.70.2
	itertools@0.14.0
	itertools@0.15.0
	itoa@1.0.18
	jiff-core@0.1.1
	jiff-static@0.2.38
	jiff-tzdb-platform@0.1.3
	jiff-tzdb@0.1.9
	jiff@0.2.38
	jni-macros@0.22.4
	jni-sys-macros@0.4.1
	jni-sys@0.4.1
	jni@0.22.4
	jobserver@0.1.35
	js-sys@0.3.106
	jsonpath-rust@1.0.12
	jsonwebtoken@11.1.0
	k8s-openapi@0.28.0
	kasuari@0.4.13
	konst@0.2.20
	konst_macro_rules@0.2.19
	kube-client@4.2.0
	kube-core@4.2.0
	kube@4.2.0
	kunobi-auth@1.1.0
	kunobi-daemon@0.10.3
	kunobi-ha@0.6.1
	kunobi-openidconnect@4.0.1-kunobi.1
	kunobi-ssh-agent-client-rs@1.1.4-kunobi.1
	lab@0.11.0
	lazy_static@1.5.1
	libc@0.2.191
	libm@0.2.16
	libredox@0.1.25
	libsqlite3-sys@0.38.2
	line-clipping@0.3.8
	linux-raw-sys@0.12.1
	litemap@0.8.3
	litrs@1.0.1
	lock_api@0.4.14
	log@0.4.34
	loom@0.7.2
	lru-slab@0.1.3
	lru@0.18.5
	mac_address@1.2.1
	matchers@0.2.0
	matchit@0.8.4
	md-5@0.11.0
	memchr@2.8.3
	memmem@0.1.1
	memoffset@0.9.1
	mime@0.3.17
	minimal-lexical@0.2.1
	mio@1.2.4
	multiversion_no_op@1.0.0
	mutants@0.0.4
	nix@0.29.0
	nix@0.31.3
	nohash-hasher@0.2.0
	nom@7.1.3
	normalize-line-endings@0.3.0
	ntapi@0.4.3
	nu-ansi-term@0.50.3
	num-bigint-dig@0.8.6
	num-bigint@0.4.8
	num-conv@0.2.2
	num-derive@0.4.2
	num-integer@0.1.47
	num-iter@0.1.46
	num-traits@0.2.19
	num_threads@0.1.8
	oauth2@5.0.0
	objc2-core-foundation@0.3.2
	objc2-io-kit@0.3.2
	oci-client@0.18.0
	oci-spec@0.10.0
	olpc-cjson@0.1.4
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	open@5.4.5
	opendal-core@0.59.5
	opendal-http-transport-reqwest@0.59.5
	opendal-layer-retry@0.59.5
	opendal-service-fs@0.59.5
	opendal-service-gcs@0.59.5
	opendal-service-s3@0.59.5
	openssl-probe@0.2.1
	option-ext@0.2.0
	ordered-float@2.10.1
	ordered-float@4.6.0
	ordered-multimap@0.7.3
	p256@0.13.2
	p256@0.14.0
	p384@0.13.1
	p384@0.14.0
	p521@0.13.3
	palette@0.7.7
	palette_derive@0.7.7
	palette_math@0.7.7
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	pbkdf2@0.12.2
	pem-rfc7468@0.7.0
	pem-rfc7468@1.0.0
	pem@3.0.6
	percent-encoding@2.3.2
	pest@2.9.4
	pest_derive@2.9.4
	pest_generator@2.9.4
	pest_meta@2.9.4
	phf@0.11.3
	phf_codegen@0.11.3
	phf_generator@0.11.3
	phf_macros@0.11.3
	phf_shared@0.11.3
	pin-project-lite@0.2.17
	pkcs1@0.7.5
	pkcs5@0.7.1
	pkcs8@0.10.2
	pkcs8@0.11.0
	pkg-config@0.3.34
	portable-atomic-util@0.2.8
	portable-atomic@1.15.0
	potential_utf@0.1.6
	powerfmt@0.2.1
	ppv-lite86@0.2.21
	predicates-core@1.0.10
	predicates-tree@1.0.13
	predicates@3.1.4
	primefield@0.14.0
	primeorder@0.13.6
	primeorder@0.14.0
	proc-macro2@1.0.107
	prometheus@0.14.0
	proptest@1.12.0
	protobuf-support@3.7.2
	protobuf@3.7.2
	psm@0.1.24
	quick-xml@0.42.0
	quinn-proto@0.11.19
	quinn-udp@0.5.16
	quinn@0.11.12
	quote@1.0.47
	r-efi@5.3.0
	r-efi@6.0.0
	rand@0.10.3
	rand@0.8.8
	rand_chacha@0.3.1
	rand_core@0.10.1
	rand_core@0.6.4
	rand_pcg@0.10.2
	rand_xorshift@0.5.0
	ratatui-core@0.1.2
	ratatui-crossterm@0.1.2
	ratatui-macros@0.7.2
	ratatui-termina@0.1.0
	ratatui-termwiz@0.1.2
	ratatui-widgets@0.3.2
	ratatui@0.30.2
	recvmsg@1.0.0
	redox_syscall@0.5.18
	redox_users@0.5.3
	ref-cast-impl@1.0.27
	ref-cast@1.0.27
	regex-automata@0.4.18
	regex-syntax@0.8.11
	regex@1.13.1
	reqsign-aws-core@3.2.0
	reqsign-aws-v4@3.3.1
	reqsign-core@3.3.2
	reqsign-file-read-tokio@3.0.7
	reqsign-google@3.2.0
	reqwest@0.12.28
	reqwest@0.13.5
	rfc6979@0.4.0
	rfc6979@0.6.0
	ring@0.17.14
	rsa@0.9.10
	rsqlite-vfs@0.1.1
	rusqlite@0.40.2
	rust-ini@0.21.3
	rustc-hash@2.1.3
	rustc_version@0.4.1
	rustix@1.1.5
	rustls-native-certs@0.8.5
	rustls-pki-types@1.15.1
	rustls-platform-verifier-android@0.2.0
	rustls-platform-verifier@0.7.1
	rustls-webpki@0.103.16
	rustls@0.23.46
	rustversion@1.0.23
	ryu@1.0.23
	salsa20@0.10.2
	same-file@1.0.6
	schannel@0.1.30
	schemars@0.9.0
	schemars@1.2.3
	scoped-tls@1.0.1
	scopeguard@1.2.0
	scrypt@0.11.0
	sec1@0.7.3
	sec1@0.8.1
	secrecy@0.10.3
	security-framework-sys@2.17.0
	security-framework@3.7.0
	semver@1.0.28
	serde-saphyr@0.0.29
	serde-value@0.7.0
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.154
	serde_path_to_error@0.1.20
	serde_plain@1.0.2
	serde_spanned@1.1.2
	serde_urlencoded@0.7.1
	serde_with@3.24.0
	serde_with_macros@3.24.0
	serdect@0.4.3
	sha1@0.11.0
	sha2@0.10.9
	sha2@0.11.1
	sharded-slab@0.1.7
	shlex@2.0.1
	signal-hook-mio@0.2.5
	signal-hook-registry@1.4.8
	signal-hook@0.3.18
	signature@2.2.0
	signature@3.0.0
	simd_cesu8@1.2.0
	simdutf8@0.1.5
	simple_asn1@0.6.4
	siphasher@1.0.4
	slab@0.4.12
	smallvec@1.15.2
	smoothutf8@0.2.3
	socket2@0.6.5
	spin@0.10.1
	spin@0.9.9
	spki@0.7.3
	spki@0.8.1
	sqlite-wasm-rs@0.5.5
	ssh-cipher@0.2.0
	ssh-encoding@0.2.0
	ssh-key@0.6.7
	stable_deref_trait@1.2.1
	stacker@0.1.25
	static_assertions@1.1.0
	strsim@0.11.1
	strum@0.27.2
	strum@0.28.0
	strum_macros@0.27.2
	strum_macros@0.28.0
	subtle@2.6.1
	syn@1.0.109
	syn@2.0.119
	syn@3.0.9
	sync_wrapper@1.0.2
	synstructure@0.14.0
	sysinfo@0.39.6
	tar@0.4.46
	tempfile@3.27.0
	termina@0.3.3
	terminfo@0.9.0
	termios@0.3.3
	termtree@0.5.1
	termwiz@0.23.3
	thiserror-impl@1.0.69
	thiserror-impl@2.0.21
	thiserror@1.0.69
	thiserror@2.0.21
	thread_local@1.1.10
	time-core@0.1.9
	time-macros@0.2.32
	time@0.3.55
	tiny-keccak@2.0.2
	tinystr@0.8.5
	tinyvec@1.13.3
	tokio-macros@2.7.2
	tokio-rustls@0.26.6
	tokio-util@0.7.20
	tokio@1.54.1
	toml@1.1.8+spec-1.1.0
	toml_datetime@1.1.2+spec-1.1.0
	toml_edit@0.25.17+spec-1.1.0
	toml_parser@1.1.5+spec-1.1.0
	toml_writer@1.1.3+spec-1.1.0
	tower-http@0.6.11
	tower-layer@0.3.3
	tower-service@0.3.3
	tower@0.5.3
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-log@0.2.0
	tracing-subscriber@0.3.23
	tracing@0.1.44
	try-lock@0.2.5
	typenum@1.20.1
	ucd-trie@0.1.7
	unarray@0.1.4
	unicase@2.10.0
	unicode-ident@1.0.27
	unicode-normalization@0.1.25
	unicode-segmentation@1.13.3
	unicode-truncate@2.0.1
	unicode-width@0.2.2
	unicode-xid@0.2.6
	untrusted@0.9.0
	url@2.5.8
	utf8_iter@1.0.4
	utf8parse@0.2.2
	uuid@1.28.0
	valuable@0.1.1
	vcpkg@0.2.15
	version_check@0.9.5
	vtparse@0.6.2
	wait-timeout@0.2.1
	walkdir@2.5.0
	want@0.3.2
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.4+wasi-0.2.12
	wasm-bindgen-futures@0.4.79
	wasm-bindgen-macro-support@0.2.129
	wasm-bindgen-macro@0.2.129
	wasm-bindgen-shared@0.2.129
	wasm-bindgen@0.2.129
	wasm-streams@0.5.0
	web-sys@0.3.106
	web-time@1.1.0
	webpki-root-certs@1.0.11
	webpki-roots@1.0.11
	wezterm-bidi@0.2.3
	wezterm-blob-leases@0.1.1
	wezterm-color-types@0.3.0
	wezterm-dynamic-derive@0.1.1
	wezterm-dynamic@0.2.1
	wezterm-input-types@0.1.0
	widestring@1.2.1
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-collections@0.3.2
	windows-core@0.62.2
	windows-future@0.3.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-numerics@0.3.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.52.0
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows-threading@0.2.1
	windows@0.62.2
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6
	winnow@1.0.4
	wit-bindgen@0.57.1
	wnaf@0.14.1
	writeable@0.6.4
	xattr@1.6.1
	yoke-derive@0.8.4
	yoke@0.8.4
	zerocopy-derive@0.8.63
	zerocopy@0.8.63
	zerofrom-derive@0.1.8
	zerofrom@0.1.8
	zeroize@1.9.1
	zeroize_derive@1.5.0
	zerotrie@0.2.5
	zerovec-derive@0.11.7
	zerovec@0.11.9
	zmij@1.0.23
	zstd-safe@8.2.0
	zstd-sys@2.1.2+zstd.1.5.7
	zstd@0.14.3
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
	${CARGO_CRATE_URIS}
"

LICENSE="Apache-2.0"
# Dependent crate licenses
LICENSE+="
	0BSD Apache-2.0 BSD CC0-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0
	Unicode-3.0 Unicode-DFS-2016 WTFPL-2 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

QA_FLAGS_IGNORED="usr/bin/kache usr/bin/kache-engine"

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
	cargo_src_test --lib --bins
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
