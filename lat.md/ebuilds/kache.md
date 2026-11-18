# kache

Kache 2.1.1 builds from upstream source with local Btrfs store compression and a rustdoc probe test fix.

## Packaging

[[dev-util/kache/kache-2.1.1.ebuild]] installs the compiler cache, its matching engine, native compiler launchers, shell completions, and a system compiler shim directory.

The package builds `kache`, `kache-engine`, `kache-cl`, and `kache-clang-cl` for amd64 and arm64. `/usr/lib/kache` contains the canonical compiler, Cargo, and rustdoc shims with the upstream marker that prevents recursive compiler discovery. `/etc/env.d/10kache` puts these shims ahead of compilers in login PATHs; root's ROOTPATH is unaffected.

Run `kache init` per user to configure Cargo and the user service. `kache init --shims /usr/lib/kache` reuses the installed shims, and `kache doctor --probe` checks compilation, storage, and restoration. Upstream 2.1.1 changes cache keys; entries refill without manually clearing the cache.

Registry dependencies and their licenses come from the patched workspace lockfile through [[kache#Dependency bundle]]. The ebuild fetches the source archive and one dependency bundle, then builds offline. It removes the root manifest's blanket warning denial so new compiler warnings do not break packaging.

### Daemon upgrades

Installation prints restart guidance; daemon replacement runs in the owning user's cache context through Kache's lifecycle protocol.

The next newer-release client [[kache:src/daemon_lifecycle.rs#ensure_outcome|drains and replaces an older daemon]], using its service manager when that manager owns the instance. Release comparisons ignore same-version rebuilds and build metadata. After a local rebuild, finish active builds and run `kache daemon restart` as the owning user with the affected cache's configuration; [[kache:src/daemon.rs#restart|explicit restart]] also replaces a daemon whose version is unknown.

There is no reload or re-exec signal. [[kache:src/platform.rs#wait_for_shutdown|SIGTERM and SIGINT]] request shutdown; [[kache:src/daemon.rs#accept_loop|request draining]] permits 30 seconds before aborting remaining handlers. A clean exit leaves a user service stopped until another client starts it. The post-install phase therefore does not signal processes or run Kache as root to restart user caches.

## Local patches

The versioned patches in [[dev-util/kache/files]] preserve opt-in store compression and serialize a test that depends on the process environment.

Store compression rewrites fresh, unshared Btrfs outputs before the store reflinks them, allowing the build tree and cache to share compressed extents. It leaves shared extents untouched and stores outputs normally if compression is unsupported or fails. Compression is off by default.

Configure `[cache] store_compression` and `store_compression_level` in `~/.config/kache/config.toml`, or use `KACHE_STORE_COMPRESSION` and `KACHE_STORE_COMPRESSION_LEVEL`. Environment settings take precedence unless environment overrides are disabled. Algorithms are zstd, zlib, and lzo; older kernels that reject explicit levels fall back to the filesystem default.

The rustdoc probe memo test takes the process-state lock while it observes environment-dependent memo keys. Workspace library and binary unit tests cover the patched configuration parser, compression policy, filesystem behavior, and compiler path. Daemon-driven integration tests remain outside the ebuild test phase because they are unreliable under Portage's sandbox.

For source tests, use an isolated `RUSTUP_HOME`: receipt-evidence tests reject symlinked compiler files in host Rustup registrations. Set `KACHE_TEST_BTRFS_DIR` to a writable Btrfs scratch directory with automatic compression disabled so fixtures start uncompressed. This exercises compression and shared-extent checks; tmpfs only covers unsupported-filesystem behavior.

Unit tests can also auto-start the installed engine with temporary home or cache directories. Detached daemons survive test exit, and idle shutdown is disabled by default. Check for test-owned processes after source tests and stop them before deleting their fixtures. Identify each by its executable, temporary cache paths, and start time; SIGTERM drains a leftover whose control socket has already been removed.

## Source checkout

The `kache` external source resolves [[kache:README.md|upstream documentation]] through `~/dev/mirrors/kache` on this machine.

[[lat.md/lat.md]] pins upstream v2.1.1. The ignored `lat.md/config.local.yaml` selects the local checkout and patched commit on `elprans/patches-2.1.1`. The repository's local `.codex/config.toml` includes the mirror in `sandbox_workspace_write.writable_roots`; a new Codex session loads this permission setting.

Follow [[ebuilds#Patch maintenance]] when bumping: review upstream behavior, rebase each local feature and its tests together, and export the source commits as versioned patches. Refresh [[kache#Dependency bundle]], regenerate the Manifest, and validate preparation, build, installation, and workspace unit tests.

## Dependency bundle

Registry crates are bundled with `pycargoebuild` and published as a versioned GitHub release asset, following [[codex#Dependency bundle]].

The bundle contains all 603 registry crates from the 2.1.1 lockfile, including Cargo checksum metadata, under `cargo_home/gentoo`. The cargo eclass unpacks them into its offline vendor directory. `CRATES` stays empty, and `pycargoebuild` refreshes dependency licenses in the existing ebuild.

Generate the bundle from the patched source checkout using a writable distfiles directory:

```sh
pycargoebuild --write-crate-tarball --no-manifest \
  --distdir /tmp/kache-2.1.1-distfiles \
  --input dev-util/kache/kache-2.1.1.ebuild \
  --crate-tarball-path /tmp/kache-2.1.1-distfiles/kache-2.1.1-deps.tar.xz \
  ~/dev/mirrors/kache
```

[The release](https://github.com/elprans/gentoo-overlay/releases/tag/kache-2.1.1) uses tag and title `kache-2.1.1`, targets `master`, and carries `kache-2.1.1-deps.tar.xz`. Publish each new version's bundle before updating the ebuild URL and Manifest:

```sh
gh release create kache-2.1.1 --repo elprans/gentoo-overlay \
  --target master --title kache-2.1.1 \
  --notes "Vendored dependency tarball for the kache 2.1.1 ebuild." \
  /tmp/kache-2.1.1-distfiles/kache-2.1.1-deps.tar.xz
gh release view kache-2.1.1 --repo elprans/gentoo-overlay --json assets
DISTDIR=/tmp/kache-2.1.1-distfiles \
  ebuild dev-util/kache/kache-2.1.1.ebuild manifest
```

Verify the uploaded asset digest against the local SHA256 before regenerating the Manifest. The ebuild fetches `https://github.com/elprans/gentoo-overlay/releases/download/${P}/${P}-deps.tar.xz`; every version has its own bundle.
